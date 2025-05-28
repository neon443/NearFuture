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
	@StateObject var viewModel: EventViewModel = EventViewModel()
	@StateObject var settingsModel: SettingsViewModel = SettingsViewModel()
	
	var body: some Scene {
		WindowGroup {
			ContentView(
				viewModel: viewModel,
				settingsModel: settingsModel
			)
		}
		.defaultSize(width: 550, height: 650)
		.commands {
			NearFutureCommands()
		}
		
		Window("About Near Future", id: "about") {
			
		}
		
		Settings {
			Text("wip")
		}
	}
}
