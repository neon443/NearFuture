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
	
	var body: some View {
		AddEventView(
			viewModel: viewModel,
			event: event,
			adding: false //bc we editing existing event
		)
		.navigationTitle("Edit Event")
	}
}

#Preview {
	let vm = dummyEventViewModel()
	EditEventView(
		viewModel: vm,
		event: .constant(vm.example)
	)
}
