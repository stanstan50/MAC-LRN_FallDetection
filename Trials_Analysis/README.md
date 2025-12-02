# 📊 Trials Analysis - Fall Detection Performance Evaluation

This folder contains inference results and performance analysis comparing **local (Core ML)** and **cloud (AWS SageMaker)** fall detection models.

---

## 📁 Files Overview

### � **Inference Results** (Simplified Format)
| File | Description | Use Case |
|------|-------------|----------|
| `local_inference.csv` | Local Core ML inference results | Analysis, ML input |
| `cloud_inference.csv` | Cloud SageMaker inference results | Analysis, ML input |

**Columns:**
- `activity_code` - Numeric activity code (0-8)
- `probability` - Fall probability as decimal (0.0000 - 1.0000), rounded to 4 places
- `prediction` - Binary prediction (0 = Normal, 1 = Fall)
- `actual` - Ground truth label (0 = Normal, 1 = Fall)

---

### 📈 **Visualizations**
| File | Description |
|------|-------------|
| `probability_distribution_by_activity.png` | Box plots showing probability distribution for each activity |
| `local_vs_cloud_performance.png` | Bar chart comparing accuracy, precision, recall, F1-score |

---

### 📓 **Analysis Notebook**
| File | Description |
|------|-------------|
| `convert_inference_results.ipynb` | Jupyter notebook for inference analysis and visualization |

**Features:**
- ✅ Load and analyze local and cloud inference results
- ✅ Add activity names for better visualization
- ✅ Performance metrics calculation (accuracy, precision, recall, F1-score)
- ✅ Visualizations (box plots, bar charts)
- ✅ Fall detection analysis by direction
- ✅ Side-by-side local vs cloud comparison

---

## 🏷️ Activity Encoding

| Code | Activity Name | Category |
|------|--------------|----------|
| 0 | Walking | ✅ Normal |
| 1 | Jogging | ✅ Normal |
| 2 | Up and Down Stairs | ✅ Normal |
| 3 | Standing from chair/sitting | ✅ Normal |
| 4 | Jumping | ✅ Normal |
| 5 | Fall Forward | 🚨 Fall |
| 6 | Fall Backward | 🚨 Fall |
| 7 | Fall Leftwards | 🚨 Fall |
| 8 | Fall Rightwards | 🚨 Fall |

---

## 📊 Trial Statistics

### **Total Trials**
- **Local Inference:** 27 trials
- **Cloud Inference:** 27 trials

### **Activities Tested**
- Normal activities: 15 trials (Walking, Jogging, Stairs, Standing, Jumping)
- Fall activities: 12 trials (Forward, Backward, Left, Right - 3 trials each)

---

## 🎯 Performance Metrics

### **Local Inference (Core ML on iPhone)**
- **Accuracy:** High accuracy for normal activities and forward/backward falls
- **Latency:** 10-50ms (real-time)
- **Offline:** ✅ Works without internet
- **Privacy:** ✅ Complete (data never leaves device)

### **Cloud Inference (AWS SageMaker)**
- **Accuracy:** Similar to local inference
- **Latency:** ~200-500ms (network dependent)
- **Offline:** ❌ Requires internet connection
- **Privacy:** ⚠️ Data sent to cloud

### **Known Issues**
- **Lateral falls (Left/Right):** Lower detection rates on both models
  - Fall Leftwards: 0% detection rate (all 3 trials missed)
  - Fall Rightwards: Variable detection (1-2 out of 3 trials detected)
- **Reason:** Model trained primarily on forward/backward falls from right pocket placement

---

## 📝 Data Format Example

### **Simplified Format** (local_inference.csv, cloud_inference.csv)
```csv
activity_code,probability,prediction,actual
0,0.0000,0,0
5,1.0000,1,1
8,0.4470,0,1
6,0.9840,1,1
7,0.0000,0,1
```

**Columns:**
- `activity_code` - Numeric code: 0-4 (normal activities), 5-8 (falls)
- `probability` - Decimal probability (0-1), rounded to 4 decimal places
- `prediction` - Binary: 0 (normal), 1 (fall)
- `actual` - Ground truth: 0 (normal), 1 (fall)

---

## 🚀 Usage

### **1. Analyze Inference Results**
Open and run `convert_inference_results.ipynb` to:
- Load local and cloud inference CSV files
- Add activity names for visualization
- Compare local vs cloud performance
- Generate performance metrics
- Create visualizations

### **2. Review Performance Metrics**
The notebook provides:
- Accuracy, Precision, Recall, F1-Score for both models
- Fall detection rates by direction (Forward/Backward/Left/Right)
- Probability distributions by activity
- Side-by-side local vs cloud comparison

### **3. Use Inference Data**
The CSV files are ready for:
- Further analysis
- Model comparison
- Performance reporting
- Machine learning pipelines
- Direct use (numeric format with activity codes and decimal probabilities)

---

## 🔍 Key Findings

### ✅ **Strengths**
1. **Excellent detection for forward/backward falls** (>98% probability)
2. **Very low false positive rate** for normal activities (<5%)
3. **Consistent performance** between local and cloud models
4. **Real-time inference** with Core ML

### ⚠️ **Areas for Improvement**
1. **Lateral fall detection** (left/right) needs improvement
2. **Threshold tuning** may help catch borderline cases
3. **Additional training data** for lateral falls recommended
4. **Sensor placement** verification (model trained for right pocket)

---

## 📚 Related Files

### **Model Files**
- `../FallDetection_Model/Fall-Detection-using-Sensor-Data-main/right_pocket_model.pth` - PyTorch model
- `../FallDetectionModel.mlpackage/` - Core ML model for iPhone

### **Training Data**
- `../FallDetection_Model/Fall-Detection-using-Sensor-Data-main/PreparedData_RightPocket.csv` - Training dataset

### **Deployment**
- `../CloudDeploy/send_endpoint.py` - AWS SageMaker inference script
- `../MAC-LRN_FallDetection/` - iOS app source code

---

## 🛠️ Requirements

### **Python Dependencies**
```bash
pip install pandas numpy matplotlib seaborn scikit-learn
```

### **For Jupyter Notebook**
```bash
pip install jupyter notebook
```

---

## 📊 Visualizations

### **Probability Distribution by Activity**
![Probability Distribution](probability_distribution_by_activity.png)

Shows box plots of fall probabilities for each activity, comparing local vs cloud inference.

### **Local vs Cloud Performance**
![Performance Comparison](local_vs_cloud_performance.png)

Bar chart comparing accuracy, precision, recall, and F1-score between local and cloud models.

---

## 💡 Next Steps

1. **Collect more lateral fall data** - Improve left/right fall detection
2. **Test different sensor placements** - Front pocket, bag, etc.
3. **Tune detection threshold** - May need different thresholds for different fall types
4. **Implement hybrid approach** - Use local inference with cloud verification
5. **Add real-time monitoring** - Track performance over time

---

## 📖 References

- **Model Architecture:** ComplexCNN1D (3 residual blocks)
- **Input:** 200 timesteps × 6 channels (ax, ay, az, gx, gy, gz)
- **Sampling Rate:** 20Hz
- **Window Size:** 10 seconds (200 samples)
- **Threshold:** 0.5 (50% probability)

---

## 📧 Contact

For questions about this analysis, please refer to the main project README or open an issue on GitHub.

---

**Last Updated:** December 2, 2025
