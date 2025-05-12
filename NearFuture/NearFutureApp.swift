//
//  NearFutureApp.swift
//  NearFuture
//
//  Created by neon443 on 24/12/2024.
//

import SwiftUI
import SwiftData

@main
struct NearFutureApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
	@StateObject var settingsModel: SettingsViewModel = SettingsViewModel()
    var body: some Scene {
        WindowGroup {
			ContentView(
				viewModel: EventViewModel(),
				settingsModel: settingsModel
			)
			.tint(settingsModel.settings.tint.color)
        }
//        .modelContainer(sharedModelContainer)
    }
}
