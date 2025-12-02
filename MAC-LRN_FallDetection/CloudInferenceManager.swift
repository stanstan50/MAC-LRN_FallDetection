//
//  CloudInferenceManager.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 12/2/25.
//
//  CloudInferenceManager.swift
//  FallDetectionComplete
//
//  Handles AWS SageMaker cloud inference
//

import Foundation
import AWSCore
import AWSSageMakerRuntime

class CloudInferenceManager: ObservableObject {
    // MARK: - Published Properties
    @Published var lastPrediction: String = "Waiting for data..."
    @Published var lastProbability: Double = 0.0
    @Published var fallDetected: Bool = false
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String? = nil
    @Published var lastLatencyMs: Double = 0.0  // NEW: Latency tracking
    
    // MARK: - AWS Configuration
    private let endpointName = "right-pocket-endpoint"
    private let region = AWSRegionType.APSoutheast2
    
    // ⚠️ TODO: Replace with your AWS credentials
    private let accessKey = "YOUR_ACCESS_KEY_ID"
    private let secretKey = "YOUR_SECRET_ACCESS_KEY"
    
    // MARK: - Private Properties
    private var requestStartTime: CFAbsoluteTime = 0.0
    
    // MARK: - Initialization
    init() {
        configureAWS()
    }
    
    // MARK: - Configure AWS
    private func configureAWS() {
        let credentialsProvider = AWSStaticCredentialsProvider(
            accessKey: accessKey,
            secretKey: secretKey
        )
        
        let configuration = AWSServiceConfiguration(
            region: region,
            credentialsProvider: credentialsProvider
        )
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        print("✅ [CLOUD] AWS configured")
    }
    
    // MARK: - Predict Fall
    func predictFall(sensorWindow: [[Double]]) {
        guard sensorWindow.count == 200, sensorWindow.first?.count == 6 else {
            print("❌ [CLOUD] Invalid window size")
            return
        }
        
        isProcessing = true
        errorMessage = nil
        requestStartTime = CFAbsoluteTimeGetCurrent()  // Start timer
        
        let batchInput = [sensorWindow]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: batchInput) else {
            print("❌ [CLOUD] JSON serialization failed")
            errorMessage = "Failed to prepare data"
            isProcessing = false
            return
        }
        
        print("📤 [CLOUD] Sending request to SageMaker...")
        
        let runtime = AWSSageMakerRuntime.default()
        let request = AWSSageMakerRuntimeInvokeEndpointInput()
        request?.endpointName = endpointName
        request?.contentType = "application/json"
        request?.body = jsonData
        
        runtime.invokeEndpoint(request!).continueWith { [weak self] task in
            guard let self = self else { return nil }
            
            // Calculate latency
            let endTime = CFAbsoluteTimeGetCurrent()
            let latencyMs = (endTime - self.requestStartTime) * 1000.0
            
            DispatchQueue.main.async {
                self.isProcessing = false
                self.lastLatencyMs = latencyMs
                
                if let error = task.error {
                    let errorDescription = error.localizedDescription
                    print("❌ [CLOUD] Error: \(errorDescription)")
                    
                    // Set user-friendly error message
                    if errorDescription.contains("security token") || errorDescription.contains("invalid") {
                        self.errorMessage = "⚠️ Invalid AWS credentials"
                        self.lastPrediction = "Auth Error"
                    } else if errorDescription.contains("internet") || errorDescription.contains("network") {
                        self.errorMessage = "⚠️ No internet connection"
                        self.lastPrediction = "Network Error"
                    } else if errorDescription.contains("endpoint") {
                        self.errorMessage = "⚠️ SageMaker endpoint not found"
                        self.lastPrediction = "Endpoint Error"
                    } else {
                        self.errorMessage = "⚠️ Cloud error: \(errorDescription)"
                        self.lastPrediction = "Error"
                    }
                    return
                }
                
                guard let result = task.result,
                      let responseBody = result.body else {
                    print("❌ [CLOUD] No response")
                    self.errorMessage = "⚠️ No response from server"
                    self.lastPrediction = "No Response"
                    return
                }
                
                print("⏱️ [CLOUD] Latency: \(String(format: "%.1f", latencyMs)) ms")
                self.parseResponse(responseBody)
            }
            return nil
        }
    }
    
    // MARK: - Parse Response
    private func parseResponse(_ data: Data) {
        // Clear any previous errors
        errorMessage = nil
        
        // Try multiple formats
        if let resultArray = try? JSONSerialization.jsonObject(with: data) as? [Double],
           let probability = resultArray.first {
            updatePrediction(probability: probability)
            return
        }
        
        if let probability = try? JSONSerialization.jsonObject(with: data) as? Double {
            updatePrediction(probability: probability)
            return
        }
        
        if let nestedArray = try? JSONSerialization.jsonObject(with: data) as? [[Double]],
           let firstArray = nestedArray.first,
           let probability = firstArray.first {
            updatePrediction(probability: probability)
            return
        }
        
        print("❌ [CLOUD] Failed to parse response")
        errorMessage = "⚠️ Invalid response format"
        lastPrediction = "Parse Error"
    }
    
    // MARK: - Update Prediction
    private func updatePrediction(probability: Double) {
        lastProbability = probability
        fallDetected = probability >= 0.5
        errorMessage = nil  // Clear errors on success
        
        if fallDetected {
            lastPrediction = "⚠️ FALL DETECTED (Cloud)"
            print("⚠️ [CLOUD] FALL DETECTED! Probability: \(String(format: "%.1f%%", probability * 100))")
            SoundManager.shared.playFallAlert(source: .cloud)
        } else {
            lastPrediction = "✅ Normal Activity"
            print("✅ [CLOUD] Normal - Probability: \(String(format: "%.1f%%", probability * 100))")
        }
    }
    
    // MARK: - Reset
    func reset() {
        lastPrediction = "Waiting for data..."
        lastProbability = 0.0
        fallDetected = false
        isProcessing = false
        errorMessage = nil
        lastLatencyMs = 0.0
    }
}
