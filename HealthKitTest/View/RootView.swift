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
                Text("読み取り")
            }
        }
        .padding()
    }
}

#Preview {
    RootView()
}


