//
//  EditEventView.swift
//  NearFuture
//
//  Created by neon443 on 02/01/2025.
//

import SwiftUI

struct EditEventView: View {
	@Environment(\.dismiss) var dismiss
	@ObservedObject var viewModel: EventViewModel
	@Binding var event: Event
	
	fileprivate func saveEdits() {		
		//if there is an event in vM.events with the id of the event we r editing,
		//firstindex - loops through the arr and finds first element where that events id matches editing event's id
		if let index = viewModel.events.firstIndex(where: { xEvent in
			xEvent.id == event.id
		}) {
			viewModel.events[index] = event
		}
		viewModel.saveEvents()
		
		dismiss()
	}
	
	var body: some View {
		AddEventView(
			viewModel: viewModel,
			event: $event,
			adding: false //bc we editing existing event
		)
		.navigationTitle("Edit Event")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button() {
					saveEdits()
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
	let vm = dummyEventViewModel()
	EditEventView(
		viewModel: vm,
		event: .constant(vm.example)
	)
}
