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
	
	@State private var searchInput: String = ""
	
	var filteredEvents: [Event] {
		if searchInput.isEmpty {
			if settingsModel.settings.showCompletedInHome {
				return viewModel.events
			} else {
				return viewModel.events.filter() { !$0.complete }
			}
		} else {
			return viewModel.events.filter {
				$0.name.localizedCaseInsensitiveContains(searchInput) ||
				$0.notes.localizedCaseInsensitiveContains(searchInput)
			}
		}
	}
	
    var body: some View {
		ScrollView {
			ForEach(viewModel.events) { event in
				if filteredEvents.contains(event) {
					EventListView(viewModel: viewModel, event: event)
						.id(event)
						.contextMenu() {
							Button(role: .destructive) {
								viewModel.removeEvent(event)
							} label: {
								Label("Delete", systemImage: "trash")
									.tint(.red)
							}
						}
				}
			}
		}
		.searchable(text: $searchInput)
		.scrollContentBackground(.hidden)
    }
}

#Preview {
	HomeView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}
