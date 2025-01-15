//
//  RootView.swift
//  HealthKitTestWatch Watch App
//
//  Created by t&a on 2025/01/13.
//

import SwiftUI

struct RootView: View {
    @StateObject private var healthKitManager = WorkoutManager()
    
    var body: some View {
        List {
            
            Text(healthKitManager.log)
            
            if healthKitManager.isError {
                Text("ERROR")
                    .foregroundStyle(.red)
            }
            
            Button {
                healthKitManager.start()
                
            } label: {
                Text(healthKitManager.isWorkoutActive ? "Workout中" : "START")
            }.disabled(healthKitManager.isWorkoutActive)
            
            Button {
                if healthKitManager.isWorkoutActive {
                    healthKitManager.stop()
                } else {
                    healthKitManager.resume()
                }
            } label: {
                Text(healthKitManager.isWorkoutActive ? "STOP" : "再開")
            }
            
            Button {
                healthKitManager.end()
            } label: {
                Text("END")
            }.disabled(!healthKitManager.isWorkoutActive)
            
        }.padding()
            .onAppear {
                Task {
                    await healthKitManager.requestAuthorization()
                }
            }
    }
}

#Preview {
    RootView()
}
