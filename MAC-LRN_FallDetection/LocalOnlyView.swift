//
//  LocalOnlyView.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 12/2/25.
//
//  Page 1: Local CoreML inference only (cloud disabled)
//

import SwiftUI

struct LocalOnlyView: View {
    // MARK: - State Objects
    @StateObject private var sensorManager = SensorDataManager.shared
    @StateObject private var localInference = LocalInferenceManager()
    
    // MARK: - State
    @State private var isMonitoring = false
    @State private var timer: Timer?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("📱 Local Inference Only")
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
                    
                    Image(systemName: statusIcon)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                .animation(.easeInOut, value: localInference.fallDetected)
                
                // Prediction Text
                Text(localInference.lastPrediction)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(localInference.fallDetected ? .red : .primary)
                    .multilineTextAlignment(.center)
                
                // Probability
                Text(String(format: "Fall Probability: %.1f%%", localInference.lastProbability * 100))
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
                    Text("Local inference every 2.5 seconds")
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
        localInference.fallDetected ? .red : .green
    }
    
    private var statusIcon: String {
        localInference.fallDetected ? "exclamationmark.triangle.fill" : "checkmark.circle.fill"
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
                    localInference.predictFall(sensorWindow: window)
                }
            }
        }
        
        print("✅ Local monitoring started")
    }
    
    private func stopMonitoring() {
        sensorManager.stopCollecting()
        timer?.invalidate()
        timer = nil
        print("🛑 Local monitoring stopped")
    }
}
