//
//  EditEventView.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 02/01/2025.
//

import SwiftUI

struct EditEventView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var viewModel: EventViewModel
	
	@State var event: Event
	
	init(viewModel: EventViewModel, event: Event) {
		self.viewModel = viewModel
		self.event = event
	}
	
	var body: some View {
//		NavigationStack {
			AddEventView(
				viewModel: viewModel,
				event: $event,
				adding: false //bc we editing existing event
			)
			.navigationTitle("Edit Event")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button() {
						viewModel.updateEvent(event)
						dismiss()
					} label: {
						Text("Done")
					}
					.disabled(event.name == "")
				}
			}
//		}
	}
}

#Preview {
	EditEventView(
		viewModel: EventViewModel(),
		event: Event(
			name: "event",
			complete: false,
			completeDesc: "dofajiof",
			symbol: "star",
			color: ColorCodable(.orange),
			notes: "lksdjfakdflkasjlkjl",
			date: Date(),
			time: true,
			recurrence: .daily
		)
	)
}
