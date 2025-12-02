//
//  CloudOnlyView.swift
//  FallDetectionCombined
//
//  Page 2: Cloud AWS SageMaker inference only (local disabled)
//

import SwiftUI

struct CloudOnlyView: View {
    // MARK: - State Objects
    @StateObject private var sensorManager = SensorDataManager.shared
    @StateObject private var cloudInference = CloudInferenceManager()
    
    // MARK: - State
    @State private var isMonitoring = false
    @State private var timer: Timer?
    @State private var isSinglePrediction = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("☁️ Cloud Inference Only")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Spacer()
                
                // Status Circle
                ZStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 150, height: 150)
                        .shadow(radius: 10)
                    
                    if cloudInference.isProcessing {
                        ProgressView()
                            .scaleEffect(2)
                            .tint(.white)
                    } else {
                        Image(systemName: statusIcon)
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                }
                .animation(.easeInOut, value: cloudInference.fallDetected)
                .animation(.easeInOut, value: cloudInference.isProcessing)
                
                // Prediction Text
                Text(cloudInference.lastPrediction)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(cloudInference.fallDetected ? .red : .primary)
                    .multilineTextAlignment(.center)
                
                // Probability
                Text(String(format: "Fall Probability: %.1f%%", cloudInference.lastProbability * 100))
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Buffer Status
                VStack(spacing: 8) {
                    Text("Buffer: \(sensorManager.sensorBuffer.count)/200 samples")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: Double(sensorManager.sensorBuffer.count), total: 200)
                        .frame(width: 200)
                }
                
                // Processing Indicator
                if cloudInference.isProcessing {
                    HStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Sending to AWS SageMaker...")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Control Buttons
                HStack(spacing: 15) {
                    // Single Prediction Button
                    Button(action: startSinglePrediction) {
                        VStack(spacing: 4) {
                            Image(systemName: "waveform.circle.fill")
                                .font(.title2)
                            Text("Single")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isSinglePrediction ? Color.orange : Color.green)
                        .cornerRadius(15)
                    }
                    .disabled(isMonitoring || isSinglePrediction)
                    
                    // Continuous Monitoring Button
                    Button(action: toggleMonitoring) {
                        VStack(spacing: 4) {
                            Image(systemName: isMonitoring ? "stop.circle.fill" : "play.circle.fill")
                                .font(.title2)
                            Text(isMonitoring ? "Stop" : "Continuous")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isMonitoring ? Color.red : Color.blue)
                        .cornerRadius(15)
                    }
                    .disabled(isSinglePrediction)
                }
                .padding(.horizontal)
                
                if isMonitoring {
                    Text("Cloud inference every 2.5 seconds")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                } else if isSinglePrediction {
                    Text("Recording 200 samples...")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .navigationTitle("Fall Detection")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Computed Properties
    private var statusColor: Color {
        if cloudInference.isProcessing {
            return .orange
        } else if cloudInference.fallDetected {
            return .red
        } else {
            return .green
        }
    }
    
    private var statusIcon: String {
        cloudInference.fallDetected ? "exclamationmark.triangle.fill" : "checkmark.circle.fill"
    }
    
    // MARK: - Methods
    private func startSinglePrediction() {
        isSinglePrediction = true
        sensorManager.startCollecting()
        
        // Poll buffer until we have exactly 200 samples
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if sensorManager.hasFullWindow() {
                timer?.invalidate()
                timer = nil
                
                // Perform single inference
                if let window = sensorManager.getCurrentWindow() {
                    print("📊 Sending single prediction to AWS SageMaker...")
                    cloudInference.predictFall(sensorWindow: window)
                }
                
                // Stop collecting
                sensorManager.stopCollecting()
                isSinglePrediction = false
                
                print("✅ Single prediction completed")
            }
        }
        
        print("🔵 Starting single prediction mode...")
    }
    
    private func toggleMonitoring() {
        isMonitoring.toggle()
        
        if isMonitoring {
            startMonitoring()
        } else {
            stopMonitoring()
        }
    }
    
    private func startMonitoring() {
        sensorManager.startCollecting()
        
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            if sensorManager.hasFullWindow() {
                if let window = sensorManager.getCurrentWindow() {
                    print("📊 Sending window to AWS SageMaker...")
                    cloudInference.predictFall(sensorWindow: window)
                }
            } else {
                print("⏳ Waiting for full buffer... (\(sensorManager.sensorBuffer.count)/200)")
            }
        }
        
        print("✅ Cloud monitoring started")
    }
    
    private func stopMonitoring() {
        sensorManager.stopCollecting()
        timer?.invalidate()
        timer = nil
        print("🛑 Cloud monitoring stopped")
    }
}
