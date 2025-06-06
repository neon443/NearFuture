//
//  ArchiveView.swift
//  NearFuture
//
//  Created by neon443 on 25/04/2025.
//

import SwiftUI

struct ArchiveView: View {
	@ObservedObject var viewModel: EventViewModel
	@State var showAddEvent: Bool = false
	var filteredEvents: [Event] {
		return viewModel.events.filter() {$0.complete}
	}
	var body: some View {
		NavigationStack {
			ZStack {
				backgroundGradient
				if viewModel.events.filter({$0.complete}).isEmpty {
					HelpView(showAddEvent: $showAddEvent)
				} else {
					ScrollView {
						ForEach(filteredEvents) { event in
							EventListView(viewModel: viewModel, event: event)
								.transition(.moveAndFadeReversed)
								.id(event.complete)
						}
						.padding(.horizontal)
					}
					.animation(.default, value: filteredEvents)
				}
			}
			.scrollContentBackground(.hidden)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					AddEventButton(showingAddEventView: $showAddEvent)
				}
			}
			.navigationTitle("Archive")
			.apply {
				if #available(iOS 17, *) {
					$0.toolbarTitleDisplayMode(.inlineLarge)
				} else {
					$0.navigationBarTitleDisplayMode(.inline)
				}
			}
		}
		.sheet(isPresented: $showAddEvent) {
			AddEventView(
				viewModel: viewModel,
				eventName: $viewModel.editableTemplate.name,
				eventComplete: $viewModel.editableTemplate.complete,
				eventCompleteDesc: $viewModel.editableTemplate.completeDesc,
				eventSymbol: $viewModel.editableTemplate.symbol,
				eventColor: $viewModel.editableTemplate.color.colorBind,
				eventNotes: $viewModel.editableTemplate.notes,
				eventDate: $viewModel.editableTemplate.date,
				eventRecurrence: $viewModel.editableTemplate.recurrence,
				adding: true
			)
		}
	}
}

#Preview {
	ArchiveView(viewModel: dummyEventViewModel())
}
