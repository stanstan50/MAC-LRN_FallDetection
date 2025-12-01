//
//  LocalInferenceManager.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 12/2/25.
//
//  Handles local CoreML inference
//

import Foundation
import CoreML

class LocalInferenceManager: ObservableObject {
    // MARK: - Published Properties
    @Published var lastPrediction: String = "Waiting for data..."
    @Published var lastProbability: Double = 0.0
    @Published var fallDetected: Bool = false
    @Published var isProcessing: Bool = false
    
    // MARK: - Private Properties
    private var model: FallDetectionModel?
    
    // MARK: - Initialization
    init() {
        loadModel()
    }
    
    // MARK: - Load CoreML Model
    private func loadModel() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all
            model = try FallDetectionModel(configuration: config)
            print("✅ [LOCAL] CoreML model loaded")
        } catch {
            print("❌ [LOCAL] Failed to load model: \(error)")
        }
    }
    
    // MARK: - Predict Fall
    func predictFall(sensorWindow: [[Double]]) {
        guard let model = model else {
            print("❌ [LOCAL] Model not loaded")
            return
        }
        
        guard sensorWindow.count == 200, sensorWindow.first?.count == 6 else {
            print("❌ [LOCAL] Invalid window size")
            return
        }
        
        isProcessing = true
        
        do {
            // Prepare MLMultiArray
            let inputArray = try MLMultiArray(shape: [1, 6, 200], dataType: .float32)
            
            for t in 0..<200 {
                for c in 0..<6 {
                    let index = [0, c, t] as [NSNumber]
                    inputArray[index] = NSNumber(value: sensorWindow[t][c])
                }
            }
            
            // Create FallDetectionModelInput
            let input = FallDetectionModelInput(sensor_data: inputArray)
            
            // Run inference
            let prediction = try model.prediction(input: input)
            let probability = Double(truncating: prediction.fall_probability[0])
            
            // Update UI
            DispatchQueue.main.async { [weak self] in
                self?.isProcessing = false
                self?.updatePrediction(probability: probability)
            }
            
        } catch {
            print("❌ [LOCAL] Prediction error: \(error)")
            isProcessing = false
        }
    }
    
    // MARK: - Update Prediction
    private func updatePrediction(probability: Double) {
        lastProbability = probability
        fallDetected = probability >= 0.5
        
        if fallDetected {
            lastPrediction = "⚠️ FALL DETECTED (Local)"
            print("⚠️ [LOCAL] FALL DETECTED! Probability: \(String(format: "%.1f%%", probability * 100))")
            SoundManager.shared.playFallAlert(source: .local)
        } else {
            lastPrediction = "✅ Normal Activity"
            print("✅ [LOCAL] Normal - Probability: \(String(format: "%.1f%%", probability * 100))")
        }
    }
    
    // MARK: - Reset
    func reset() {
        lastPrediction = "Waiting for data..."
        lastProbability = 0.0
        fallDetected = false
        isProcessing = false
    }
}
