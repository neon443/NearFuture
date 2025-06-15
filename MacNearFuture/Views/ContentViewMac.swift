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
	
	@State private var showAddEventView: Bool = false
	@State private var symbolSearchInput: String = ""
	
    var body: some View {
		NavigationSplitView {
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
				NavigationLink {
					SymbolsPicker(
						selection: .constant(""),
						browsing: true
					)
				} label: {
					Image(systemName: "star.circle")
					Text("Symbols")
				}
				NavigationLink {
					SettingsView(
						viewModel: viewModel,
						settingsModel: settingsModel
					)
				} label: {
					Image(systemName: "gear")
					Text("Settings")
				}
			}
		} detail: {
			Text("Welcome to Near Future")
		}
		.tint(settingsModel.settings.tint.color)
		.frame(minWidth: 450, minHeight: 550)
		.containerBackground(.regularMaterial, for: .window)
		.sheet(isPresented: $settingsModel.settings.showWhatsNew) {
			WhatsNewView(settingsModel: settingsModel)
				.presentationSizing(.form)
		}
		.sheet(isPresented: $showAddEventView) {
			AddEventView(
				viewModel: viewModel
			)
			.presentationSizing(.page)
		}
		.toolbar {
			Button() {
				showAddEventView.toggle()
			} label: {
				Label("New", systemImage: "plus")
			}
		}
    }
}

#Preview {
	ContentView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}
