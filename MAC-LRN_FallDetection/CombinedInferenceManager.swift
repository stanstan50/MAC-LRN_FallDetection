//
//  CombinedInferenceManager.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 12/2/25.
//
//  Manages both local and cloud inference simultaneously
//
//
//  CombinedInferenceManager.swift
//  FallDetectionComplete
//
//  Manages both local and cloud inference simultaneously
//

import Foundation

class CombinedInferenceManager: ObservableObject {
    // MARK: - Published Properties
    @Published var localEnabled: Bool = true
    @Published var cloudEnabled: Bool = true
    
    @Published var localPrediction: String = "Waiting..."
    @Published var cloudPrediction: String = "Waiting..."
    
    @Published var localProbability: Double = 0.0
    @Published var cloudProbability: Double = 0.0
    
    @Published var localFallDetected: Bool = false
    @Published var cloudFallDetected: Bool = false
    
    @Published var isProcessing: Bool = false
    @Published var cloudErrorMessage: String? = nil  // NEW: Cloud error display
    
    // MARK: - Private Managers
    private let localManager = LocalInferenceManager()
    private let cloudManager = CloudInferenceManager()
    
    // MARK: - Predict With Both (shared buffer)
    func predictWithBoth(sensorWindow: [[Double]]) {
        isProcessing = true
        
        // Run enabled inference modes
        if localEnabled {
            localManager.predictFall(sensorWindow: sensorWindow)
        }
        
        if cloudEnabled {
            cloudManager.predictFall(sensorWindow: sensorWindow)
        }
        
        // Update combined state after a delay to let inference complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.updateCombinedState()
        }
    }
    
    // MARK: - Update Combined State
    private func updateCombinedState() {
        // Update local state
        if localEnabled {
            localPrediction = localManager.lastPrediction
            localProbability = localManager.lastProbability
            localFallDetected = localManager.fallDetected
        }
        
        // Update cloud state
        if cloudEnabled {
            cloudPrediction = cloudManager.lastPrediction
            cloudProbability = cloudManager.lastProbability
            cloudFallDetected = cloudManager.fallDetected
            cloudErrorMessage = cloudManager.errorMessage  // NEW: Sync error state
        }
        
        isProcessing = false
        
        // Check if both detected fall
        if localEnabled && cloudEnabled && localFallDetected && cloudFallDetected {
            print("🚨 [BOTH] Local AND Cloud detected fall!")
            SoundManager.shared.playFallAlert(source: .both)
        }
    }
    
    // MARK: - Reset
    func reset() {
        localManager.reset()
        cloudManager.reset()
        localPrediction = "Waiting..."
        cloudPrediction = "Waiting..."
        localProbability = 0.0
        cloudProbability = 0.0
        localFallDetected = false
        cloudFallDetected = false
        isProcessing = false
        cloudErrorMessage = nil
    }
}
