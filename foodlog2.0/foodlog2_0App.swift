//
//  foodlog2_0App.swift
//  foodlog2.0
//
//  Created by Miguel Pereira on 2025-03-30.
//

import SwiftUI

@main
struct foodlog2_0App: App {
    @StateObject private var nutritionStore = NutritionStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(nutritionStore)
        }
    }
}
