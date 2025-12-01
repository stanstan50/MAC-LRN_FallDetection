import torch
import torch.nn as nn
import torch.nn.functional as F
import json
import numpy as np
import boto3
from datetime import datetime
import os

# S3 config (can also use environment variables)
BUCKET_NAME = "sagemaker-sensor-data"
PREFIX = "sensor-data"
REGION = "ap-southeast-2"
columns = ['rp_acc_x', 'rp_acc_y', 'rp_acc_z', 'rp_gyro_x', 'rp_gyro_y', 'rp_gyro_z', 'activity']
s3 = boto3.client("s3")
ses = boto3.client("ses", region_name="ap-southeast-2")

SENDER = "otamatont@gmail.com"
RECIPIENT = "otamatont02@gmail.com"

# -----------------------------
# MODEL DEFINITION (same as training)
# -----------------------------
class ComplexCNN1D(nn.Module):
    def __init__(self, input_shape):
        super(ComplexCNN1D, self).__init__()
        self.input_shape = input_shape
        self.conv1 = nn.Conv1d(in_channels=input_shape[1], out_channels=64, kernel_size=3, padding='same')
        self.bn1 = nn.BatchNorm1d(64)
        self.dropout1 = nn.Dropout(0.3)
        self.conv2_shortcut = nn.Conv1d(64, 128, 1, padding='same')
        self.conv2_1 = nn.Conv1d(64, 128, 3, padding='same')
        self.bn2_1 = nn.BatchNorm1d(128)
        self.dropout2 = nn.Dropout(0.3)
        self.conv2_2 = nn.Conv1d(128, 128, 3, padding='same')
        self.bn2_2 = nn.BatchNorm1d(128)
        self.maxpool2 = nn.MaxPool1d(2)
        self.conv3_shortcut = nn.Conv1d(128, 256, 1, padding='same')
        self.conv3_1 = nn.Conv1d(128, 256, 3, padding='same')
        self.bn3_1 = nn.BatchNorm1d(256)
        self.dropout3 = nn.Dropout(0.4)
        self.conv3_2 = nn.Conv1d(256, 256, 3, padding='same')
        self.bn3_2 = nn.BatchNorm1d(256)
        self.maxpool3 = nn.MaxPool1d(2)
        self.conv4_shortcut = nn.Conv1d(256, 512, 1, padding='same')
        self.conv4_1 = nn.Conv1d(256, 512, 3, padding='same')
        self.bn4_1 = nn.BatchNorm1d(512)
        self.dropout4 = nn.Dropout(0.5)
        self.conv4_2 = nn.Conv1d(512, 512, 3, padding='same')
        self.bn4_2 = nn.BatchNorm1d(512)
        self.maxpool4 = nn.MaxPool1d(2)
        self.global_avg_pool = nn.AdaptiveAvgPool1d(1)
        self.fc1 = nn.Linear(512, 1024)
        self.dropout5 = nn.Dropout(0.6)
        self.fc2 = nn.Linear(1024, 512)
        self.dropout6 = nn.Dropout(0.6)
        self.fc3 = nn.Linear(512, 1)

    def forward(self, x):
        x = F.relu(self.conv1(x))
        x = self.bn1(x)
        x = self.dropout1(x)
        shortcut = self.conv2_shortcut(x)
        x = F.relu(self.conv2_1(x))
        x = self.bn2_1(x)
        x = self.dropout2(x)
        x = F.relu(self.conv2_2(x))
        x = self.bn2_2(x)
        x = x + shortcut
        x = self.maxpool2(x)
        shortcut = self.conv3_shortcut(x)
        x = F.relu(self.conv3_1(x))
        x = self.bn3_1(x)
        x = self.dropout3(x)
        x = F.relu(self.conv3_2(x))
        x = self.bn3_2(x)
        x = x + shortcut
        x = self.maxpool3(x)
        shortcut = self.conv4_shortcut(x)
        x = F.relu(self.conv4_1(x))
        x = self.bn4_1(x)
        x = self.dropout4(x)
        x = F.relu(self.conv4_2(x))
        x = self.bn4_2(x)
        x = x + shortcut
        x = self.maxpool4(x)
        x = self.global_avg_pool(x)
        x = x.view(x.size(0), -1)
        x = F.relu(self.fc1(x))
        x = self.dropout5(x)
        x = F.relu(self.fc2(x))
        x = self.dropout6(x)
        x = torch.sigmoid(self.fc3(x))
        return x

# -----------------------------
# SAGEMAKER FUNCTIONS
# -----------------------------
def model_fn(model_dir):
    input_shape = (200, 6)
    model = ComplexCNN1D(input_shape)
    model.load_state_dict(torch.load(f"{model_dir}/right_pocket_model.pth", map_location=torch.device('cpu')))
    model.eval()
    return model

def input_fn(request_body, request_content_type):
    if request_content_type == "application/json":
        data = np.array(json.loads(request_body))
        return torch.tensor(data, dtype=torch.float32).permute(0, 2, 1)
    else:
        raise ValueError(f"Unsupported content type: {request_content_type}")


def send_email_alert(sensor_record):
    subject = "Fall Detected!"
    body = (
        "A fall was detected by the model.\n\n"
        f"Timestamp: {sensor_record['timestamp']}\n"
        f"Prediction: {sensor_record['prediction']}\n"
        f"Input sensor data: {sensor_record['input']}\n"
    )

    ses.send_email(
        Source=SENDER,
        Destination={"ToAddresses": [RECIPIENT]},
        Message={
            "Subject": {"Data": subject},
            "Body": {"Text": {"Data": body}}
        }
    )


def predict_fn(input_data, model):
    with torch.no_grad():
        outputs = model(input_data)
        pred = outputs.numpy()

    # Prepare S3 payload
    record = {
        "timestamp": datetime.utcnow().isoformat(),
        "input": input_data.tolist(),
        "prediction": pred.tolist()
    }

    # Save to S3 as JSON
    key = f"requests/{datetime.utcnow().strftime('%Y-%m-%d_%H-%M-%S-%f')}.json"

    s3.put_object(
        Bucket=BUCKET_NAME,
        Key=key,
        Body=json.dumps(record),
        ContentType="application/json"
    )

    # Send email only if fall detected (prediction == 1)
    if float(pred) >= 0.5:
        try:
            send_email_alert(record)
        except Exception as e:
            print("SES error:", e)
            
    return pred

def output_fn(prediction, content_type):
    return json.dumps(prediction.tolist())
