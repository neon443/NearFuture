//
//  ArchiveView.swift
//  MacNearFuture
//
//  Created by neon443 on 28/05/2025.
//

import SwiftUI

struct ArchiveView: View {
	@StateObject var viewModel: EventViewModel
	@StateObject var settingsModel: SettingsViewModel
	
	var filteredEvents: [Event] {
		return viewModel.events.filter { $0.complete }
	}
	
	var body: some View {
		ScrollView {
			ForEach(filteredEvents) { event in
				EventListView(viewModel: viewModel, event: event)
					.contextMenu() {
						Button(role: .destructive) {
							viewModel.removeEvent(event)
						} label: {
							Label("Delete", systemImage: "trash")
								.tint(.red )
						}
					}
			}
		}
		.scrollContentBackground(.hidden)
	}
}

#Preview {
	ArchiveView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}
