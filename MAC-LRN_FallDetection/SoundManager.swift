//
//  SoundManager.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 12/2/25.
//
//  Plays different alert sounds for local vs cloud detection
//

import Foundation
import AVFoundation

enum FallDetectionSource {
    case local
    case cloud
    case both
}

class SoundManager {
    static let shared = SoundManager()
    
    private init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to set up audio session: \(error)")
        }
    }
    
    // MARK: - Play Alert Based on Source
    func playFallAlert(source: FallDetectionSource) {
        switch source {
        case .local:
            playLocalAlert()
        case .cloud:
            playCloudAlert()
        case .both:
            playBothAlert()
        }
    }
    
    // MARK: - Local Detection Alert
    private func playLocalAlert() {
        // System sound 1005 - short alert beep
        AudioServicesPlaySystemSound(1005)
        
        // Single vibration
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        print("🔊 [LOCAL] Playing fall alert + vibration")
    }
    
    // MARK: - Cloud Detection Alert
    private func playCloudAlert() {
        // System sound 1013 - different tone
        AudioServicesPlaySystemSound(1013)
        
        // Double vibration
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        print("🔊 [CLOUD] Playing fall alert + double vibration")
    }
    
    // MARK: - Both Detected Alert
    private func playBothAlert() {
        // System sound 1016 - urgent tone
        AudioServicesPlaySystemSound(1016)
        
        // Triple vibration (urgent pattern)
        for i in 0..<3 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
        
        print("🔊 [BOTH] Playing urgent alert + triple vibration")
    }
}
