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
	@State var hey: UUID = UUID()
	var body: some View {
		NavigationStack {
			ZStack {
				backgroundGradient
				if viewModel.events.filter({$0.complete}).isEmpty {
					HelpView(showAddEvent: $showAddEvent)
				} else {
					ScrollView {
						ForEach(viewModel.events.filter({$0.complete})) { event in
							EventListView(viewModel: viewModel, event: event)
						}
						.padding(.horizontal)
						.id(hey)
						.onReceive(viewModel.objectWillChange) {
							hey = UUID()
						}
					}
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
			.presentationDragIndicator(.visible)
			.apply {
				if #available(iOS 16.4, *) {
					$0.presentationBackground(.ultraThinMaterial)
				}
			}
		}
	}
}

#Preview {
	ArchiveView(viewModel: dummyEventViewModel())
}


