//
//  RootView.swift
//  HealthKitTestWatch Watch App
//
//  Created by t&a on 2025/01/13.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var healthKitManager = WorkoutManager()
    
    var body: some View {
        VStack {
            Button {
                healthKitManager.start()
                
            } label: {
                Text(healthKitManager.isStart ? "NOW" : "START")
            }
            
            Button {
                if healthKitManager.isStart {
                    healthKitManager.stop()
                    healthKitManager.isStart = false
                } else {
                    healthKitManager.resume()
                    healthKitManager.isStart = true
                }
                
               
            } label: {
                Text(healthKitManager.isStart ? "STOP" : "resume")
            }
            
            
            Button {
                healthKitManager.end()
            } label: {
                Text("END")
            }
            
            
        }
        .padding()
        .onAppear {
            print("---onAppear")
            Task {
                await healthKitManager.requestAuthorization()
            }
           
        }
    }
}

#Preview {
    RootView()
}
