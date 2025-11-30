import torch
import torch.nn as nn
import torch.nn.functional as F
import os

# Define the model architecture (copied from Modeling.ipynb)
class ComplexCNN1D(nn.Module):
    def __init__(self, input_shape):
        super(ComplexCNN1D, self).__init__()
        self.input_shape = input_shape

        # Initial Conv Layer
        self.conv1 = nn.Conv1d(in_channels=input_shape[1], out_channels=64, kernel_size=3, padding='same')
        self.bn1 = nn.BatchNorm1d(64)
        self.dropout1 = nn.Dropout(0.3)
        # First Residual Block
        self.conv2_shortcut = nn.Conv1d(in_channels=64, out_channels=128, kernel_size=1, padding='same')
        self.conv2_1 = nn.Conv1d(in_channels=64, out_channels=128, kernel_size=3, padding='same')
        self.bn2_1 = nn.BatchNorm1d(128)
        self.dropout2 = nn.Dropout(0.3)
        self.conv2_2 = nn.Conv1d(in_channels=128, out_channels=128, kernel_size=3, padding='same')
        self.bn2_2 = nn.BatchNorm1d(128)
        self.maxpool2 = nn.MaxPool1d(kernel_size=2)

        # Second Residual Block
        self.conv3_shortcut = nn.Conv1d(in_channels=128, out_channels=256, kernel_size=1, padding='same')
        self.conv3_1 = nn.Conv1d(in_channels=128, out_channels=256, kernel_size=3, padding='same')
        self.bn3_1 = nn.BatchNorm1d(256)
        self.dropout3 = nn.Dropout(0.4)
        self.conv3_2 = nn.Conv1d(in_channels=256, out_channels=256, kernel_size=3, padding='same')
        self.bn3_2 = nn.BatchNorm1d(256)
        self.maxpool3 = nn.MaxPool1d(kernel_size=2)

        # Third Residual Block
        self.conv4_shortcut = nn.Conv1d(in_channels=256, out_channels=512, kernel_size=1, padding='same')
        self.conv4_1 = nn.Conv1d(in_channels=256, out_channels=512, kernel_size=3, padding='same')
        self.bn4_1 = nn.BatchNorm1d(512)
        self.dropout4 = nn.Dropout(0.5)
        self.conv4_2 = nn.Conv1d(in_channels=512, out_channels=512, kernel_size=3, padding='same')
        self.bn4_2 = nn.BatchNorm1d(512)
        self.maxpool4 = nn.MaxPool1d(kernel_size=2)

        # Global Average Pooling and Fully Connected Layers
        self.global_avg_pool = nn.AdaptiveAvgPool1d(1)
        self.fc1 = nn.Linear(512, 1024)
        self.dropout5 = nn.Dropout(0.6)
        self.fc2 = nn.Linear(1024, 512)
        self.dropout6 = nn.Dropout(0.6)
        self.fc3 = nn.Linear(512, 1)

    def forward(self, x):
        # Initial Conv Layer
        x = F.relu(self.conv1(x))
        x = self.bn1(x)
        x = self.dropout1(x)

        # First Residual Block
        shortcut = self.conv2_shortcut(x)
        x = F.relu(self.conv2_1(x))
        x = self.bn2_1(x)
        x = self.dropout2(x)
        x = F.relu(self.conv2_2(x))
        x = self.bn2_2(x)
        x = x + shortcut  # Residual connection
        x = self.maxpool2(x)

        # Second Residual Block
        shortcut = self.conv3_shortcut(x)
        x = F.relu(self.conv3_1(x))
        x = self.bn3_1(x)
        x = self.dropout3(x)
        x = F.relu(self.conv3_2(x))
        x = self.bn3_2(x)
        x = x + shortcut  # Residual connection
        x = self.maxpool3(x)

        # Third Residual Block
        shortcut = self.conv4_shortcut(x)
        x = F.relu(self.conv4_1(x))
        x = self.bn4_1(x)
        x = self.dropout4(x)
        x = F.relu(self.conv4_2(x))
        x = self.bn4_2(x)
        x = x + shortcut  # Residual connection
        x = self.maxpool4(x)

        # Global Average Pooling and Fully Connected Layers
        x = self.global_avg_pool(x)
        x = x.view(x.size(0), -1)  # Flatten
        x = F.relu(self.fc1(x))
        x = self.dropout5(x)
        x = F.relu(self.fc2(x))
        x = self.dropout6(x)
        x = torch.sigmoid(self.fc3(x))  # Sigmoid activation for binary classification

        return x

def convert():
    print("Loading PyTorch model...")
    input_shape = (200, 24)
    model = ComplexCNN1D(input_shape)
    
    # Check if best_model.pth exists
    if not os.path.exists('best_model.pth'):
        print("Error: best_model.pth not found.")
        return

    # Load weights
    try:
        model.load_state_dict(torch.load('best_model.pth', map_location=torch.device('cpu')))
    except Exception as e:
        print(f"Error loading model: {e}")
        return

    model.eval()

    # Create dummy input
    # Shape: (1, 24, 200)
    dummy_input = torch.randn(1, 24, 200)

    print("Tracing model with TorchScript...")
    traced_script_module = torch.jit.trace(model, dummy_input)
    
    output_path = "model.pt"
    traced_script_module.save(output_path)
    print(f"TorchScript model saved to {output_path}")

if __name__ == "__main__":
    convert()
