//
//  MacNearFutureApp.swift
//  MacNearFuture
//
//  Created by neon443 on 21/05/2025.
//

import Foundation
import SwiftUI

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
			.frame(minWidth: 350, minHeight: 450)
		}
		.defaultSize(width: 450, height: 550)
	}
}
