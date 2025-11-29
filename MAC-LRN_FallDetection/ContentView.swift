//
//  ContentView.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 11/29/25.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    private let motion = CMMotionManager()
    @State private var accel: CMAcceleration = .init()
    @State private var gyro: CMRotationRate = .init()

    var body: some View {
        VStack(spacing: 25) {
            Text("📱 Live Motion Data")
                .font(.title2)
                .bold()

            VStack {
                Text("Accelerometer (g)")
                    .font(.headline)
                Text("x: \(accel.x, specifier: "%.4f")")
                Text("y: \(accel.y, specifier: "%.4f")")
                Text("z: \(accel.z, specifier: "%.4f")")
            }

            VStack {
                Text("Gyroscope (rad/s)")
                    .font(.headline)
                Text("x: \(gyro.x, specifier: "%.4f")")
                Text("y: \(gyro.y, specifier: "%.4f")")
                Text("z: \(gyro.z, specifier: "%.4f")")
            }
        }
        .padding()
        .onAppear {
            startMotionUpdates()
        }
    }

    func startMotionUpdates() {
        guard motion.isAccelerometerAvailable,
              motion.isGyroAvailable else {
            print("Motion sensors not available.")
            return
        }

        motion.accelerometerUpdateInterval = 0.1
        motion.startAccelerometerUpdates()

        motion.gyroUpdateInterval = 0.1
        motion.startGyroUpdates()

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let a = motion.accelerometerData {
                accel = a.acceleration
            }
            if let g = motion.gyroData {
                gyro = g.rotationRate
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        // Previews cannot read motion sensors; they only show the UI layout.
        ContentView()
            .previewDisplayName("SmartFall Motion UI Preview")
    }
}
