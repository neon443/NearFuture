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
		let filteredEvents = viewModel.events.filter({$0.complete})
		return filteredEvents.reversed()
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
							NavigationLink() {
								EditEventView(
									viewModel: viewModel,
									event: Binding(
										get: { event },
										set: { newValue in
											viewModel.editEvent(newValue)
										}
									)
								)
							} label: {
								EventListView(viewModel: viewModel, event: event)
									.id(event.complete)
							}
							.transition(.moveAndFadeReversed)
						}
						.padding(.horizontal)
					}
					.animation(.default, value: filteredEvents)
				}
			}
			.transition(.opacity)
			.scrollContentBackground(.hidden)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					AddEventButton(showingAddEventView: $showAddEvent)
				}
			}
			.navigationTitle("Archive")
			.modifier(navigationInlineLarge())
		}
		.sheet(isPresented: $showAddEvent) {
			AddEventView(
				viewModel: viewModel
			)
		}
	}
}

#Preview {
	ArchiveView(viewModel: dummyEventViewModel())
}
