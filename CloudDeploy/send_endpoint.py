import torch
import numpy as np
import json
import boto3


print("=" * 50)
print("Example 1: Unlikely fall")
print("=" * 50)

# Generate dummy sensor data: 6 channels, 200 timesteps
sample_data_1 = np.random.rand(200, 6)  # shape (200, 6)

# Add batch dimension
batch_input = np.expand_dims(sample_data_1, axis=0)  # shape (1, 200, 6)

# Convert to JSON string
payload = json.dumps(batch_input.tolist())


runtime = boto3.client('sagemaker-runtime', region_name='ap-southeast-2')
endpoint_name = "right-pocket-endpoint"  # replace with your endpoint name

response = runtime.invoke_endpoint(
    EndpointName=endpoint_name,
    ContentType='application/json',
    Body=payload
)

result = json.loads(response['Body'].read())
print("Predicted probability:", result)



print("=" * 50)
print("Example 2: True Fall scenario")
print("=" * 50)


# Load the saved tensor
loaded = torch.load('fall_input.pt')  # could be (1,6,200) or (6,200)

# Convert to numpy array
if isinstance(loaded, torch.Tensor):
    arr = loaded.numpy()
elif isinstance(loaded, list):
    arr = np.array(loaded)
else:
    arr = np.array(loaded)

# Remove batch dimension if present
if arr.ndim == 3 and arr.shape[0] == 1:
    arr = arr.squeeze(0)  # becomes (6, 200)

# Check shape
if arr.shape != (6, 200):
    raise ValueError(f"Unexpected input shape {arr.shape}, expected (6, 200)")

# Transpose to (timesteps, channels) → (200, 6)
arr = arr.T

# Add batch dimension → (1, 200, 6)
batch_input = np.expand_dims(arr, axis=0)

# Convert to JSON string for SageMaker
payload = json.dumps(batch_input.tolist())

print("Payload ready for SageMaker endpoint with shape:", np.array(batch_input).shape)

response = runtime.invoke_endpoint(
    EndpointName=endpoint_name,
    ContentType='application/json',
    Body=payload
)

result = json.loads(response['Body'].read())
print("Predicted probability:", result)


