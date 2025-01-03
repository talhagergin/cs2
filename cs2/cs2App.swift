//
//  cs2App.swift
//  cs2
//
//  Created by Talha Gergin on 4.01.2025.
//

import SwiftUI
import SwiftData

@main
struct cs2App: App {
    let container: ModelContainer
    
    init() {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: false)
            container = try ModelContainer(for: GameMap.self, Marker.self, User.self, configurations: config)
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
        .modelContainer(container)
    }
}
