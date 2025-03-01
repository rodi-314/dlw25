//
//  ContentView.swift
//  DLW25
//
//  Created by Brandon Kang on 1/3/25.
//

import SwiftUI

struct ContentView: View {
    @State private var heartRate: Double? = nil
    @State private var bodyTemperature: Double? = nil
    let healthKitManager = HealthKitManager()

    var body: some View {
        VStack(spacing: 30) {
            // Heart Rate Section
            VStack(spacing: 10) {
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.red)
                if let rate = heartRate {
                    Text("Heart Rate: \(Int(rate)) BPM")
                } else {
                    Text("Heart Rate: Unknown")
                }
            }
            
            // Body Temperature Section
            VStack(spacing: 10) {
                Image(systemName: "thermometer")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.orange)
                if let temp = bodyTemperature {
                    Text("Body Temperature: \(temp, specifier: "%.1f") °C")
                } else {
                    Text("Body Temperature: Unknown")
                }
            }
            
            // Fetch Data Button
            Button("Fetch Health Data") {
                // Request permissions and fetch both values
                healthKitManager.requestAuthorization { success, error in
                    if success {
                        healthKitManager.fetchCurrentHeartRate { rate in
                            DispatchQueue.main.async {
                                self.heartRate = rate
                            }
                        }
                        healthKitManager.fetchLatestBodyTemperature { temp in
                            DispatchQueue.main.async {
                                self.bodyTemperature = temp
                            }
                        }
                    } else if let error = error {
                        print("Error authorizing HealthKit: \(error)")
                    }
                }
            }
            .padding()
        }
        .padding()
    }
}
