//
//  ContentView.swift
//  MAC-LRN_FallDetection
//
//  Created by Stanley Yale Zeng on 11/29/25.
//
//  ContentView.swift
//  FallDetectionCombined
//
//  Main navigation with 4 tabs: Local, Cloud, Combined, Training
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            // Page 1: Local Inference Only
            LocalOnlyView()
                .tabItem {
                    Label("Local", systemImage: "iphone")
                }
            
            // Page 2: Cloud Inference Only
            CloudOnlyView()
                .tabItem {
                    Label("Cloud", systemImage: "cloud")
                }
            
            // Page 3: Combined Inference
            CombinedView()
                .tabItem {
                    Label("Combined", systemImage: "arrow.triangle.2.circlepath")
                }
            
            // Page 4: Training Data Collection
            TrainingDataView()
                .tabItem {
                    Label("Training", systemImage: "graduationcap")
                }
        }
    }
}

#Preview {
    ContentView()
}
