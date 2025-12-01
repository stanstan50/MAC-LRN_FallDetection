//
//  CombinedView.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 12/2/25.
//
//  Page 3: Both local and cloud inference with individual controls
//
//
//  CombinedView.swift
//  FallDetectionCombined
//
//  Page 3: Both local and cloud inference with individual controls
//

import SwiftUI

struct CombinedView: View {
    // MARK: - State Objects
    @StateObject private var sensorManager = SensorDataManager.shared
    @StateObject private var combinedManager = CombinedInferenceManager()
    
    // MARK: - State
    @State private var isMonitoring = false
    @State private var timer: Timer?
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🔄 Combined Inference")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                // Enable/Disable Controls
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "iphone")
                            .foregroundColor(.blue)
                        Toggle("Local (CoreML)", isOn: $combinedManager.localEnabled)
                            .disabled(!isMonitoring)
                    }
                    
                    HStack {
                        Image(systemName: "cloud")
                            .foregroundColor(.blue)
                        Toggle("Cloud (AWS)", isOn: $combinedManager.cloudEnabled)
                            .disabled(!isMonitoring)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Alert Mode Indicator
                HStack(spacing: 8) {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.orange)
                    Text(alertModeText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Cloud Error Banner
                if let error = combinedManager.cloudErrorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .transition(.scale)
                }
                
                Spacer()
                
                // Side-by-side status indicators
                HStack(spacing: 30) {
                    // Local Status
                    VStack(spacing: 10) {
                        Text("📱 Local")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        ZStack {
                            Circle()
                                .fill(localStatusColor)
                                .frame(width: 100, height: 100)
                                .shadow(radius: 5)
                                .opacity(combinedManager.localEnabled ? 1.0 : 0.3)
                            
                            Image(systemName: localStatusIcon)
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }
                        
                        Text(combinedManager.localPrediction)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(combinedManager.localFallDetected ? .red : .primary)
                        
                        Text(String(format: "%.1f%%", combinedManager.localProbability * 100))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Cloud Status
                    VStack(spacing: 10) {
                        Text("☁️ Cloud")
                            .font(.caption)
                            .fontWeight(.semibold)
                        
                        ZStack {
                            Circle()
                                .fill(cloudStatusColor)
                                .frame(width: 100, height: 100)
                                .shadow(radius: 5)
                                .opacity(combinedManager.cloudEnabled ? 1.0 : 0.3)
                            
                            if combinedManager.cloudEnabled && combinedManager.isProcessing {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                            } else {
                                Image(systemName: cloudStatusIcon)
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text(combinedManager.cloudPrediction)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(combinedManager.cloudFallDetected ? .red : .primary)
                        
                        Text(String(format: "%.1f%%", combinedManager.cloudProbability * 100))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Shared Buffer Status
                VStack(spacing: 8) {
                    Text("Shared Buffer: \(sensorManager.sensorBuffer.count)/200 samples")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: Double(sensorManager.sensorBuffer.count), total: 200)
                        .frame(width: 250)
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
                    Text("Synchronized inference every 2.5 seconds")
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
    private var alertModeText: String {
        if combinedManager.localEnabled && combinedManager.cloudEnabled {
            return "Alert Mode: Local (1005) | Cloud (1013) | Both (1016)"
        } else if combinedManager.localEnabled {
            return "Alert Mode: Local Only (1005)"
        } else if combinedManager.cloudEnabled {
            return "Alert Mode: Cloud Only (1013)"
        } else {
            return "Alert Mode: Disabled"
        }
    }
    
    private var localStatusColor: Color {
        combinedManager.localFallDetected ? .red : .green
    }
    
    private var cloudStatusColor: Color {
        if combinedManager.cloudErrorMessage != nil {
            return .orange
        } else if combinedManager.isProcessing {
            return .blue
        } else if combinedManager.cloudFallDetected {
            return .red
        } else {
            return .green
        }
    }
    
    private var localStatusIcon: String {
        combinedManager.localFallDetected ? "exclamationmark.triangle.fill" : "checkmark.circle.fill"
    }
    
    private var cloudStatusIcon: String {
        if combinedManager.cloudErrorMessage != nil {
            return "exclamationmark.triangle.fill"
        } else if combinedManager.cloudFallDetected {
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
        
        // Run inference every 2.5 seconds using SHARED buffer
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            if sensorManager.hasFullWindow() {
                if let window = sensorManager.getCurrentWindow() {
                    // Both use the SAME window data
                    combinedManager.predictWithBoth(sensorWindow: window)
                }
            }
        }
        
        print("✅ Combined monitoring started")
    }
    
    private func stopMonitoring() {
        sensorManager.stopCollecting()
        timer?.invalidate()
        timer = nil
        print("🛑 Combined monitoring stopped")
    }
}
