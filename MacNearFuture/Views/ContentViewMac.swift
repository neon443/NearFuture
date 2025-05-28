//
//  ContentView.swift
//  MacNearFuture
//
//  Created by neon443 on 21/05/2025.
//

import SwiftUI

struct ContentView: View {
	@StateObject var viewModel: EventViewModel
	@StateObject var settingsModel: SettingsViewModel
	
    var body: some View {
		NavigationSplitView(preferredCompactColumn: .constant(.sidebar)) {
			List {
				NavigationLink {
					HomeView(
						viewModel: viewModel,
						settingsModel: settingsModel
					)
				} label: {
					Image(systemName: "house")
					Text("Home")
				}
				NavigationLink {
					ArchiveView(
						viewModel: viewModel,
						settingsModel: settingsModel
					)
				} label: {
					Image(systemName: "tray.full")
					Text("Archive")
				}
			}
		} detail: {
			
		}
		.tint(settingsModel.settings.tint.color)
		.frame(minWidth: 450, minHeight: 550)
		.containerBackground(.ultraThinMaterial, for: .window)
    }
}

#Preview {
	ContentView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}
