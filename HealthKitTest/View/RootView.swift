//
//  RootView.swift
//  HealthKitTest
//
//  Created by t&a on 2025/01/11.
//

import SwiftUI

struct RootView: View {
    private let healthKitManager = HealthKitManager()
    var body: some View {
        VStack {
            
            Text("昨日の消費カロリー：\(healthKitManager.kilocalorie)kcal")
            
            Button {
                Task {
                    await healthKitManager.requestAuthorization()
                }
                
            } label: {
                Text("許可要求")
            }
            
            Button {
                healthKitManager.reading()
            } label: {
                Text("消費カロリー読み取り")
            }
        }
        .padding()
    }
}

#Preview {
    RootView()
}


