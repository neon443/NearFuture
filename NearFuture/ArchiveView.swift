//
//  ArchiveView.swift
//  NearFuture
//
//  Created by neon443 on 30/03/2025.
//

import SwiftUI

struct ArchiveView: View {
	@ObservedObject var viewModel: EventViewModel
	
	var body: some View {
		ForEach(viewModel.events.filter() { $0.complete == true }) { completedEvent in
			EventListView(viewModel: viewModel, event: completedEvent)
		}
	}
}

#Preview {
	var viewModel = EventViewModel()
//	viewModel.events = [
//		Event(
//			name: "Event",
//			complete: false,
//			completeDesc: "Coplete description",
//			symbol: "gear",
//			color: ColorCodable(.purple),
//			description: "loremd ipsum doret so re mi far",
//			date: Date(),
//			time: true,
//			recurrence: .daily
//		)
//	]
	ArchiveView(
		viewModel: viewModel
	)
}
