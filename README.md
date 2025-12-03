# MAC-LRN Fall Detection System

A comprehensive fall detection system for iOS devices using deep learning and smartphone sensors. The system implements both local on-device inference (Core ML) and cloud-based inference (AWS SageMaker) to provide real-time fall detection with multi-tier deployment options.

## Overview

This project explores the performance trade-offs between local and cloud-based machine learning inference for fall detection on mobile devices. Using accelerometer and gyroscope data from iPhones, the system can distinguish between normal daily activities and various types of falls.

**Key Features:**
- Real-time fall detection using smartphone sensors
- Dual deployment architecture (local and cloud)
- Support for multiple iPhone models
- Comprehensive performance analysis across accuracy and latency dimensions
- iOS native implementation with Swift

## Project Structure

```
MAC-LRN_FallDetection/
├── FallDetection_Model/          # Deep learning model development
│   └── Fall-Detection-using-Sensor-Data-main/
│       ├── Modeling.ipynb         # Model training and evaluation
│       ├── DataPreparation.ipynb  # Data preprocessing
│       ├── best_model.pth         # Trained PyTorch model
│       └── ...
├── FallDetectionModel.mlpackage/  # Core ML model for iOS
├── MAC-LRN_FallDetection/         # iOS application source code
├── CloudDeploy/                   # Cloud deployment utilities
└── Trials_Analysis/               # Performance evaluation
    ├── latency_analysis.ipynb     # Latency metrics analysis
    └── convert_inference_results.ipynb  # Accuracy analysis
```

## System Architecture

### Model Architecture
- **Type**: 1D Convolutional Neural Network (CNN) with residual connections
- **Input**: 2-second windows of sensor data (200 samples at 100 Hz)
- **Sensors**: Accelerometer (x, y, z) + Gyroscope (x, y, z)
- **Output**: Binary classification (Fall vs Non-Fall)

### Deployment Tiers

**1. Local Inference (Core ML)**
- On-device processing using iPhone's Neural Engine
- Minimal latency for real-time detection
- No internet connection required
- Privacy-preserving (data stays on device)

**2. Cloud Inference (AWS SageMaker)**
- Server-side processing for resource-constrained scenarios
- Consistent performance across devices
- Higher latency due to network transmission

**3. Combined Inference**
- Hybrid approach leveraging both local and cloud
- Fallback mechanisms for reliability

## Key Findings

### Detection Performance
- Strong overall accuracy in distinguishing falls from normal activities
- Excellent detection rates for forward and backward falls
- Lateral falls present more challenging detection scenarios
- Low false positive rates minimize unnecessary alerts
- Consistent performance across local and cloud deployments

### Latency Performance
- Local inference significantly faster than cloud inference
- Local processing suitable for real-time fall detection
- Cloud inference viable for non-critical monitoring scenarios
- Device hardware (Neural Engine generation) impacts local inference speed

### Activity Recognition
- Normal activities (walking, jogging, stairs) reliably classified as non-falls
- High-intensity activities (jumping) occasionally produce fall-like patterns
- Fall direction detection varies by sensor orientation

## Tested Devices

- iPhone 15 Pro Max (A17 Pro chip)
- iPhone 13 Mini (A15 Bionic chip)
- iPhone 11 Pro Max (A13 Bionic chip)

## Technologies Used

**Machine Learning:**
- PyTorch (model development)
- Core ML (iOS deployment)
- AWS SageMaker (cloud deployment)

**Mobile Development:**
- Swift & SwiftUI
- Core Motion (sensor access)

**Data Analysis:**
- Python, Pandas, NumPy
- Matplotlib, Seaborn (visualization)
- Scikit-learn (metrics)

## Getting Started

### Model Training
1. Navigate to `FallDetection_Model/Fall-Detection-using-Sensor-Data-main/`
2. Use `DataPreparation.ipynb` for data preprocessing
3. Open `Modeling.ipynb` to train the model


### iOS Application
1. Open `MAC-LRN_FallDetection.xcodeproj` in Xcode
2. Ensure the Core ML model (`FallDetectionModel.mlpackage`) is included
3. Configure AWS credentials for cloud inference (if using)
4. Build and run on a physical iPhone device

### Performance Analysis
1. Navigate to `Trials_Analysis/`
2. Run `latency_analysis.ipynb` for latency metrics
3. Run `convert_inference_results.ipynb` for accuracy analysis

## Use Cases

- **Elderly Care**: Monitor seniors for fall incidents and alert caregivers
- **Healthcare**: Track patient mobility and fall risk
- **Fitness**: Analyze movement patterns during physical activities
- **Research**: Study human activity recognition and fall biomechanics

## Future Enhancements

- Improve lateral fall detection with additional training data
- Implement multi-class classification for fall direction identification
- Add personalized threshold adjustment based on user activity patterns
- Optimize model size for better battery efficiency
- Explore edge computing solutions for balanced performance
- Integrate with emergency services for automatic alerts

## Research Context

This project was developed as part of research exploring mobile-cloud computing architectures for real-time health monitoring applications. The goal is to understand the trade-offs between on-device and cloud-based inference in resource-constrained mobile environments.

## Acknowledgments

This project is based on the fall detection model from [Fall-Detection-using-Sensor-Data](https://github.com/AbdulrahmenSalem/Fall-Detection-using-Sensor-Data) by AbdulrahmenSalem. The original model has been extended with iOS deployment capabilities and comprehensive performance analysis comparing local and cloud inference architectures.

---

**Note**: This system is designed for research and educational purposes. For production deployment in healthcare settings, additional validation, testing, and regulatory compliance would be required.