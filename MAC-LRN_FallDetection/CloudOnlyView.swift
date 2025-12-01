//
//  CloudOnlyView.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 12/2/25.
//
//  Page 2: Cloud AWS SageMaker inference only (local disabled)
//
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
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("☁️ Cloud Inference Only")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                Spacer()
                
                // Error Message Banner
                if let error = cloudInference.errorMessage {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                        
                        Text("Check AWS credentials in CloudInferenceManager.swift")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .transition(.scale)
                }
                
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
                if cloudInference.errorMessage == nil {
                    Text(String(format: "Fall Probability: %.1f%%", cloudInference.lastProbability * 100))
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
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
                
                // Control Button
                Button(action: toggleMonitoring) {
                    HStack {
                        Image(systemName: isMonitoring ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title3)
                        Text(isMonitoring ? "Stop Monitoring" : "Start Monitoring")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isMonitoring ? Color.red : Color.blue)
                    .cornerRadius(15)
                }
                .padding(.horizontal)
                
                if isMonitoring {
                    Text("Cloud inference every 2.5 seconds")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .navigationTitle("Fall Detection")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Computed Properties
    private var statusColor: Color {
        if cloudInference.errorMessage != nil {
            return .orange
        } else if cloudInference.isProcessing {
            return .blue
        } else if cloudInference.fallDetected {
            return .red
        } else {
            return .green
        }
    }
    
    private var statusIcon: String {
        if cloudInference.errorMessage != nil {
            return "exclamationmark.triangle.fill"
        } else if cloudInference.fallDetected {
            return "exclamationmark.triangle.fill"
        } else {
            return "checkmark.circle.fill"
        }
    }
    
    // MARK: - Methods
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
