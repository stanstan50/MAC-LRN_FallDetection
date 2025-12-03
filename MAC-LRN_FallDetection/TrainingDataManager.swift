//
//  TrainingDataManager.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 12/2/25.
//
//  TrainingDataManager.swift
//  FallDetectionComplete
//
//  Handles training data collection and sending to HTTP API (Lambda)
//

import Foundation

class TrainingDataManager: ObservableObject {
    // MARK: - Published Properties
    @Published var collectedWindow: [[Double]]? = nil
    @Published var isCollected: Bool = false
    @Published var isSending: Bool = false
    @Published var lastResponse: String = ""
    @Published var errorMessage: String? = nil
    @Published var activityLabel: Int = 0  // 0 = non-fall, 1 = fall
    
    // MARK: - API Configuration
    // ⚠️ TODO: Replace with your Lambda API endpoint URL
    private let apiEndpoint = "https://your-api-gateway-url.execute-api.region.amazonaws.com/prod/training-data"
    
    // MARK: - Initialization
    init() {
        print("✅ [TRAINING] HTTP API configured")
    }
    
    // MARK: - Collect Window
    func collectWindow(sensorWindow: [[Double]], isFall: Bool) {
        guard sensorWindow.count == 200, sensorWindow.first?.count == 6 else {
            print("❌ [TRAINING] Invalid window size")
            errorMessage = "Invalid window size"
            return
        }
        
        // Add activity label to each row
        activityLabel = isFall ? 1 : 0
        var labeledWindow: [[Double]] = []
        
        for sample in sensorWindow {
            var labeledSample = sample
            labeledSample.append(Double(activityLabel))  // Add activity column
            labeledWindow.append(labeledSample)
        }
        
        collectedWindow = labeledWindow
        isCollected = true
        errorMessage = nil
        
        print("✅ [TRAINING] Window collected with label: \(activityLabel) (\(isFall ? "FALL" : "NON-FALL"))")
        print("   Sample shape: 200 x 7 (6 sensors + 1 activity label)")
    }
    
    // MARK: - Send Training Data
    func sendTrainingData() {
        guard let window = collectedWindow else {
            print("❌ [TRAINING] No window collected")
            errorMessage = "No data to send"
            return
        }
        
        guard isCollected else {
            print("❌ [TRAINING] Window not collected yet")
            errorMessage = "Collect data first"
            return
        }
        
        isSending = true
        errorMessage = nil
        
        // Convert to CSV format
        let csvString = convertToCSV(window: window)
        guard let csvData = csvString.data(using: .utf8) else {
            print("❌ [TRAINING] CSV conversion failed")
            errorMessage = "Failed to prepare data"
            isSending = false
            return
        }
        
        print("📤 [TRAINING] Sending training data to Lambda API...")
        print("   Endpoint: \(apiEndpoint)")
        print("   Format: CSV with headers")
        print("   Data shape: 200 samples x 7 columns")
        print("   Activity label: \(activityLabel) (\(activityLabel == 1 ? "FALL" : "NON-FALL"))")
        print("   CSV size: \(csvData.count) bytes")
        
        // Create HTTP POST request
        guard let url = URL(string: apiEndpoint) else {
            print("❌ [TRAINING] Invalid API URL")
            errorMessage = "⚠️ Invalid API endpoint"
            isSending = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/csv", forHTTPHeaderField: "Content-Type")
        request.httpBody = csvData
        request.timeoutInterval = 30
        
        // Send request
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isSending = false
                
                // Handle errors
                if let error = error {
                    let errorDescription = error.localizedDescription
                    print("❌ [TRAINING] Error: \(errorDescription)")
                    
                    if errorDescription.contains("Internet") || errorDescription.contains("network") {
                        self.errorMessage = "⚠️ No internet connection"
                        self.lastResponse = "Network Error"
                    } else if errorDescription.contains("timed out") {
                        self.errorMessage = "⚠️ Request timed out"
                        self.lastResponse = "Timeout Error"
                    } else {
                        self.errorMessage = "⚠️ Error: \(errorDescription)"
                        self.lastResponse = "Error"
                    }
                    return
                }
                
                // Check HTTP response
                if let httpResponse = response as? HTTPURLResponse {
                    print("📥 [TRAINING] HTTP Status: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode == 200 {
                        // Success
                        if let data = data, let responseString = String(data: data, encoding: .utf8) {
                            print("📥 [TRAINING] Response: \(responseString)")
                            self.lastResponse = "✅ Data sent successfully"
                            self.errorMessage = nil
                            
                            // Reset after successful send
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.reset()
                            }
                        } else {
                            self.lastResponse = "✅ Data sent successfully"
                            self.errorMessage = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.reset()
                            }
                        }
                    } else {
                        // HTTP error
                        print("❌ [TRAINING] HTTP Error: \(httpResponse.statusCode)")
                        self.errorMessage = "⚠️ Server error (\(httpResponse.statusCode))"
                        self.lastResponse = "Server Error"
                        
                        if let data = data, let errorBody = String(data: data, encoding: .utf8) {
                            print("   Error body: \(errorBody)")
                        }
                    }
                } else {
                    print("❌ [TRAINING] No HTTP response")
                    self.errorMessage = "⚠️ No response from server"
                    self.lastResponse = "No Response"
                }
            }
        }.resume()
    }
    
    // MARK: - Convert to CSV
    private func convertToCSV(window: [[Double]]) -> String {
        var csv = "rp_acc_x,rp_acc_y,rp_acc_z,rp_gyro_x,rp_gyro_y,rp_gyro_z,activity\n"
        
        for sample in window {
            // sample format: [ax, ay, az, gx, gy, gz, activity]
            let row = sample.map { String($0) }.joined(separator: ",")
            csv += row + "\n"
        }
        
        return csv
    }
    
    // MARK: - Reset
    func reset() {
        collectedWindow = nil
        isCollected = false
        lastResponse = ""
        errorMessage = nil
        print("🔄 [TRAINING] Reset - ready for new trial")
    }
}
