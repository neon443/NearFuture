//
//  ContentView.swift
//  NearFuture
//
//  Created by neon443 on 24/12/2024.
//

import SwiftUI
import UserNotifications
import SwiftData

enum Field {
	case Search
}
enum Tab {
	case home
	case archive
	case stats
	case settings
}

struct ContentView: View {
	@StateObject var viewModel: EventViewModel
	@StateObject var settingsModel: SettingsViewModel
	@State var selection: Tab = .home
	
	var body: some View {
		TabView(selection: $selection) {
			HomeView(viewModel: viewModel, settingsModel: settingsModel)
			.tabItem {
				Label("Home", systemImage: "house")
			}
			.tag(Tab.home)
			ArchiveView(viewModel: viewModel)
				.tabItem() {
					Label("Archive", systemImage: "tray.full")
				}
				.tag(Tab.archive)
			StatsView(viewModel: viewModel)
				.tabItem {
					Label("Statistics", systemImage: "chart.pie")
				}
				.tag(Tab.stats)
			SettingsView(viewModel: viewModel, settingsModel: settingsModel)
				.tabItem {
					Label("Settings", systemImage: "gear")
				}
				.tag(Tab.settings)
		}
		.apply {
			if #available(iOS 17, *) {
				$0.sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: selection)
			}
		}
		.sheet(isPresented: $settingsModel.settings.showWhatsNew) {
			WhatsNewView(settingsModel: settingsModel)
		}
	}
}

#Preview {
	ContentView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}

extension View {
	var backgroundGradient: some View {
		return LinearGradient(
			gradient: Gradient(colors: [.bgTop, .two]),
			startPoint: .top,
			endPoint: .bottom
		)
		.ignoresSafeArea(.all)
	}
	
	func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

extension AnyTransition {
	static var moveAndFade: AnyTransition {
		.asymmetric(
			insertion: .move(edge: .leading),
			removal: .move(edge: .trailing)
		)
		.combined(with: .opacity)
	}
	static var moveAndFadeReversed: AnyTransition {
		.asymmetric(
			insertion: .move(edge: .trailing),
			removal: .move(edge: .leading)
		)
		.combined(with: .opacity)
	}
}
