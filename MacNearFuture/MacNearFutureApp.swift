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
	@Environment(\.openWindow) var openWindow
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
			CommandGroup(replacing: CommandGroupPlacement.appInfo) {
					Button("About Near Future") {
						openWindow(id: "about")
					}
				}
			NearFutureCommands()
		}
		
		WindowGroup("edit Event", for: Event.ID.self) { $eventID in
			EditEventView(
				viewModel: viewModel,
				event: Binding(
					get: {
						viewModel.events.first(where: {$0.id == eventID}) ?? viewModel.template
					},
					set: { newValue in
						if let eventIndex = viewModel.events.firstIndex(where: {
							$0.id == eventID
						}) {
							viewModel.events[eventIndex] = newValue
						}
						viewModel.saveEvents()
					}
				)
			)
		}
		.restorationBehavior(.disabled)
		
		Window("About Near Future", id: "about") {
			AboutView()
		}
		.windowBackgroundDragBehavior(.enabled)
		.windowResizability(.contentSize)
		.restorationBehavior(.disabled)
		.defaultPosition(UnitPoint.center)
		
		Settings {
			SettingsView(
				viewModel: viewModel,
				settingsModel: settingsModel
			)
		}
	}
}
