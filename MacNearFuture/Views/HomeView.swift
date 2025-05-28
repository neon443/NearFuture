//
//  HomeView.swift
//  MacNearFuture
//
//  Created by neon443 on 28/05/2025.
//

import SwiftUI

struct HomeView: View {
	@StateObject var viewModel: EventViewModel
	@StateObject var settingsModel: SettingsViewModel
	
	var filteredEvents: [Event] {
		switch settingsModel.settings.showCompletedInHome {
		case true:
			return viewModel.events
		case false:
			return viewModel.events.filter { !$0.complete }
		}
	}
    var body: some View {
		ScrollView {
			ForEach(filteredEvents) { event in
				EventListView(viewModel: viewModel, event: event)
			}
		}
		.scrollContentBackground(.hidden)
    }
}

#Preview {
	HomeView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}
