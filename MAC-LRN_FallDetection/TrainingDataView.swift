//
//  TrainingDataView.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 12/2/25.
//
//  TrainingDataView.swift
//  FallDetectionComplete
//
//  Page 4: Collect and send labeled training data to cloud
//

import SwiftUI

struct TrainingDataView: View {
    // MARK: - State Objects
    @StateObject private var sensorManager = SensorDataManager.shared
    @StateObject private var trainingManager = TrainingDataManager()
    
    // MARK: - State
    @State private var isCollecting = false
    @State private var timer: Timer?
    @State private var isFallTrial: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    Text("🎓 Training Data Collection")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                        .padding(.top)
                    
                    Text("Collect labeled data for model training")
                        .font(.caption)
                        .foregroundColor(.secondary)
                
                // Status Circle
                ZStack {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 150, height: 150)
                        .shadow(radius: 10)
                    
                    if trainingManager.isSending {
                        ProgressView()
                            .scaleEffect(2)
                            .tint(.white)
                    } else {
                        Image(systemName: statusIcon)
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                }
                .animation(.easeInOut, value: trainingManager.isCollected)
                .animation(.easeInOut, value: trainingManager.isSending)
                
                // Response Text
                if !trainingManager.lastResponse.isEmpty {
                    Text(trainingManager.lastResponse)
                        .font(.headline)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                }
                
                // Error Banner
                if let error = trainingManager.errorMessage {
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // Label Selection (Checkbox)
                VStack(spacing: 15) {
                    Text("Select Trial Type:")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 30) {
                        // Non-Fall Option
                        Button(action: {
                            isFallTrial = false
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: isFallTrial ? "circle" : "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(isFallTrial ? .gray : .green)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Non-Fall")
                                        .font(.headline)
                                        .foregroundColor(isFallTrial ? .secondary : .primary)
                                    Text("Label: 0")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isFallTrial ? Color(.systemGray6) : Color.green.opacity(0.1))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isFallTrial ? Color.clear : Color.green, lineWidth: 2)
                            )
                        }
                        .disabled(isCollecting || trainingManager.isCollected)
                        
                        // Fall Option
                        Button(action: {
                            isFallTrial = true
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: isFallTrial ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundColor(isFallTrial ? .red : .gray)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Fall")
                                        .font(.headline)
                                        .foregroundColor(isFallTrial ? .primary : .secondary)
                                    Text("Label: 1")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isFallTrial ? Color.red.opacity(0.1) : Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isFallTrial ? Color.red : Color.clear, lineWidth: 2)
                            )
                        }
                        .disabled(isCollecting || trainingManager.isCollected)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Buffer Status
                VStack(spacing: 8) {
                    if trainingManager.isCollected {
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Window collected: 200 samples x 7 features")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    } else {
                        Text("Buffer: \(sensorManager.sensorBuffer.count)/200 samples")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: Double(sensorManager.sensorBuffer.count), total: 200)
                            .frame(width: 250)
                    }
                }
                
                // Collection Status
                if isCollecting {
                    HStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Recording trial...")
                            .font(.caption)
                    }
                    .foregroundColor(.purple)
                }
                
                Spacer()
                
                // Control Buttons
                VStack(spacing: 12) {
                    // Start Button (Collect Data)
                    Button(action: startCollecting) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                            Text("Start Trial")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isCollecting ? Color.orange : Color.purple)
                        .cornerRadius(15)
                    }
                    .disabled(isCollecting || trainingManager.isCollected || trainingManager.isSending)
                    
                    // Send Button (Submit to API)
                    Button(action: sendToCloud) {
                        HStack(spacing: 8) {
                            Image(systemName: trainingManager.isSending ? "arrow.up.circle" : "cloud.fill")
                                .font(.title3)
                            Text(trainingManager.isSending ? "Sending..." : "Send to API")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(trainingManager.isCollected && !trainingManager.isSending ? Color.blue : Color.gray)
                        .cornerRadius(15)
                    }
                    .disabled(!trainingManager.isCollected || trainingManager.isSending)
                    
                    // Reset Button
                    if trainingManager.isCollected && !trainingManager.isSending {
                        Button(action: reset) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                                Text("Reset")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(15)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Instructions
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("1. Select trial type (Fall or Non-Fall)")
                        .font(.caption2)
                    Text("2. Press 'Start Trial' and perform activity")
                        .font(.caption2)
                    Text("3. Wait for 200 samples (~10 seconds)")
                        .font(.caption2)
                    Text("4. Press 'Send to API' to submit CSV data")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Training Data")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Computed Properties
    private var statusColor: Color {
        if trainingManager.isSending {
            return .orange
        } else if trainingManager.isCollected {
            return .green
        } else if isCollecting {
            return .purple
        } else {
            return .gray
        }
    }
    
    private var statusIcon: String {
        if trainingManager.isSending {
            return "arrow.up.circle.fill"
        } else if trainingManager.isCollected {
            return "checkmark.circle.fill"
        } else if isCollecting {
            return "record.circle"
        } else {
            return "circle.dotted"
        }
    }
    
    // MARK: - Methods
    private func startCollecting() {
        isCollecting = true
        sensorManager.startCollecting()
        
        // Poll buffer until we have exactly 200 samples
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if sensorManager.hasFullWindow() {
                timer?.invalidate()
                timer = nil
                
                // Collect window with label
                if let window = sensorManager.getCurrentWindow() {
                    trainingManager.collectWindow(sensorWindow: window, isFall: isFallTrial)
                }
                
                // Stop collecting
                sensorManager.stopCollecting()
                isCollecting = false
                
                print("✅ Trial data collected (\(isFallTrial ? "FALL" : "NON-FALL"))")
            }
        }
        
        print("🎬 Starting trial collection (\(isFallTrial ? "FALL" : "NON-FALL"))...")
    }
    
    private func sendToCloud() {
        print("📤 Sending training data to Lambda API...")
        trainingManager.sendTrainingData()
    }
    
    private func reset() {
        trainingManager.reset()
        sensorManager.sensorBuffer.removeAll()
        print("🔄 Ready for new trial")
    }
}
