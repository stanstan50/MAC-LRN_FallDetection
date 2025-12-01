//
//  SensorDataManager.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 12/2/25.
//
//  Shared sensor data collection for all inference modes
//

import Foundation
import CoreMotion

class SensorDataManager: ObservableObject {
    // MARK: - Published Properties
    @Published var sensorBuffer: [[Double]] = []
    @Published var isCollecting: Bool = false
    
    // MARK: - Private Properties
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    // Sensor configuration
    private let samplingRate: Double = 20.0  // 20 Hz
    private let windowSize: Int = 200        // 10 seconds
    
    // MARK: - Singleton
    static let shared = SensorDataManager()
    
    // MARK: - Initialization
    private init() {
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInitiated
    }
    
    // MARK: - Start Collecting
    func startCollecting() {
        guard motionManager.isDeviceMotionAvailable else {
            print("❌ Device motion not available")
            return
        }
        
        guard !isCollecting else {
            print("⚠️ Already collecting")
            return
        }
        
        sensorBuffer.removeAll()
        isCollecting = true
        
        motionManager.deviceMotionUpdateInterval = 1.0 / samplingRate
        
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motion, error in
            guard let self = self, let motion = motion else {
                if let error = error {
                    print("❌ Motion error: \(error)")
                }
                return
            }
            
            // Unit conversions
            let ax = motion.userAcceleration.x// * 9.81  // G → m/s²
            let ay = motion.userAcceleration.y// * 9.81
            let az = motion.userAcceleration.z// * 9.81
            
            let gx = motion.rotationRate.x * 180.0 / .pi  // rad/s → deg/s
            let gy = motion.rotationRate.y * 180.0 / .pi
            let gz = motion.rotationRate.z * 180.0 / .pi
            
            let sample = [ax, ay, az, gx, gy, gz]
            
            DispatchQueue.main.async {
                self.sensorBuffer.append(sample)
                
                if self.sensorBuffer.count > self.windowSize {
                    self.sensorBuffer.removeFirst()
                }
            }
        }
        
        print("✅ Started collecting sensor data at \(samplingRate) Hz")
    }
    
    // MARK: - Stop Collecting
    func stopCollecting() {
        guard isCollecting else { return }
        
        motionManager.stopDeviceMotionUpdates()
        isCollecting = false
        print("🛑 Stopped collecting sensor data")
    }
    
    // MARK: - Get Current Window
    func getCurrentWindow() -> [[Double]]? {
        guard sensorBuffer.count == windowSize else { return nil }
        return sensorBuffer
    }
    
    // MARK: - Check if Buffer is Full
    func hasFullWindow() -> Bool {
        return sensorBuffer.count == windowSize
    }
    
    deinit {
        stopCollecting()
    }
}
