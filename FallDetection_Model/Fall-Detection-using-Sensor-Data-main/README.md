# Fall Detection using Smartphone Sensor Data

This project implements a deep learning-based fall detection system using smartphone sensor data. The goal is to accurately classify whether a person has experienced a fall or is performing normal activities based on accelerometer and gyroscope readings.

## Overview

The system uses a 1D Convolutional Neural Network (CNN) with residual connections to analyze time-series sensor data and detect falls in real-time. The model has been deployed on both local iOS devices (using Core ML) and cloud infrastructure (AWS SageMaker) for comprehensive performance evaluation.

## Dataset

The dataset is collected from smartphones placed in different body positions, with primary focus on right pocket placement. The data includes:

**Sensor Readings:**
- Accelerometer: x, y, z-axis measurements
- Gyroscope: x, y, z-axis measurements
- Sampling rate: 100 Hz

**Activities:**
- Normal activities: Walking, Jogging, Stairs, Sitting/Standing, Jumping
- Fall types: Forward, Backward, Leftward, Rightward

**Source:** https://sites.google.com/up.edu.mx/har-up/

## Data Processing

The preprocessing pipeline includes:

1. **Data Cleaning**: Handling missing values and filtering out subjects with poor data quality
2. **Feature Engineering**: Renaming and organizing sensor channels for consistency
3. **Windowing Strategy**: 
   - Window size: 2 seconds (200 samples at 100 Hz)
   - Non-fall activities: No overlap
   - Fall activities: 50% overlap to balance the dataset
4. **Train/Test Split**: Stratified split to maintain class distribution

# Model Architecture
The model used in this project is a 1D Convolutional Neural Network (CNN) with residual connections. The architecture includes:

* Initial Conv Layer: A convolutional layer followed by batch normalization and dropout.

* Residual Blocks: Three residual blocks, each containing two convolutional layers with batch normalization and dropout.

* Global Average Pooling: A global average pooling layer to reduce the spatial dimensions.

* Fully Connected Layers: Two fully connected layers with dropout, followed by a final output layer with a sigmoid activation function for binary classification (fall or no fall).
  
![model_architecture (1)](https://github.com/user-attachments/assets/c61f6dc4-33f5-4dec-8678-6f6d1cc51b1a)

  

# Training
The model is trained using the following steps:

* Loss Function: Binary Cross-Entropy Loss is used as the loss function.

* Optimizer: Adam optimizer is used for training.

* Early Stopping: Early stopping is implemented to prevent overfitting.

* Training Loop: The model is trained for a specified number of epochs, and the best model is saved based on validation loss.

# Results
The model achieves the following performance on the test set:

* Accuracy: 95%

* Precision: 94% (No Fall), 97% (Fall)

* Recall: 99% (No Fall), 83% (Fall)

* F1-Score: 97% (No Fall), 90% (Fall)

![image](https://github.com/user-attachments/assets/9f64c73a-d818-46ff-bb28-6d9861b8a918)
![image](https://github.com/user-attachments/assets/115f5bfd-f5fb-4f22-b74c-770cc3301d9d)


