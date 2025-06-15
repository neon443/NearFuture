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
	@StateObject var settingsModel: SettingsViewModel = SettingsViewModel()
	var body: some Scene {
		WindowGroup {
			ContentView(
				viewModel: EventViewModel(),
				settingsModel: settingsModel
			)
			.tint(settingsModel.settings.tint.color)
		}
	}
}
