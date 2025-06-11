//
//  EditEventView.swift
//  NearFuture
//
//  Created by neon443 on 21/05/2025.
//

import SwiftUI

struct EditEventView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var viewModel: EventViewModel
	@Binding var event: Event
	
	var body: some View {
		AddEventView(
			viewModel: viewModel,
			event: $event,
			adding: false //bc we editing existing event
		)
		.navigationTitle("Edit Event")
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button() {
					dismiss()
				} label: {
					Text("Done")
						.bold()
				}
				.disabled(event.name == "")
			}
		}
	}
}

#Preview {
	EditEventView(
		viewModel: dummyEventViewModel(),
		event: .constant(dummyEventViewModel().template)
	)
}
