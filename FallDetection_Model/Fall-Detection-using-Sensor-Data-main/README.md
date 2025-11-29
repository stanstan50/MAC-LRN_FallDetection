# Fall-Detection-using-Sensor-Data
This project focuses on detecting falls using sensor data collected from wearable devices. The goal is to classify whether a person has fallen or is performing normal activities based on accelerometer and gyroscope readings. The dataset includes sensor data from multiple body parts, such as the right pocket, belt, neck, and wrist.

# Dataset
The dataset used in this project is collected from sensors placed on different body parts, including the right pocket, belt, neck, and wrist. The dataset contains the following columns:

* Accelerometer Data: x, y, z-axis readings from the accelerometer.

* Gyroscope Data: x, y, z-axis readings from the gyroscope.

* Activity Labels: The activity being performed (e.g., walking, running, falling).

* The dataset is stored in a CSV file named CompleteDataSet.csv.

* Dataset: https://sites.google.com/up.edu.mx/har-up/

# Data Preprocessing
The data preprocessing steps include:

* Loading the Dataset: The dataset is loaded and inspected for missing or inconsistent values.

* Handling Missing Values: Missing values are replaced with data from the most related subject based on age, height, and weight similarity.

* Filtering Data: Data for specific subjects with excessive null values (e.g., Subject 5 and Subject 9) are filtered out to ensure data quality.

* Renaming Columns: Columns are renamed for better readability and consistency.

* Windowing: The time-series data is segmented into fixed-length windows to prepare it for training the model.

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


