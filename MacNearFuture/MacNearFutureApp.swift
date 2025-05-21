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
			NavigationSplitView {
				List {
					NavigationLink {
						
					} label: {
						Image(systemName: "house")
						Text("Home")
					}
					NavigationLink {
						
					} label: {
						Image(systemName: "tray.full")
						Text("Archive")
					}
				}
			} detail: {
				ContentView(
					viewModel: EventViewModel(),
					settingsModel: settingsModel
				)

			}
			.tint(settingsModel.settings.tint.color)
			.frame(minWidth: 450, minHeight: 550)
			.containerBackground(.ultraThinMaterial, for: .window)
		}
		.defaultSize(width: 550, height: 650)
		.commands {
			NearFutureCommands()
			Menu("hi") {
				Button("hi") {
					
				}
			}
		}
		
		Window("About Near Future", id: "about") {
			
		}
		
		Settings {
			Text("wip")
		}
	}
}
