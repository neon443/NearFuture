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
	@Binding var event: Event
	
	@State private var eventName: String
	@State private var eventSymbol: String
	@State private var eventColor: Color
	@State private var eventDescription: String
	@State private var eventDate: Date
	@State private var eventRecurrence: Event.RecurrenceType
	
	init(viewModel: EventViewModel, event: Binding<Event>) {
		self.viewModel = viewModel
		_event = event
		_eventName = State(initialValue: event.wrappedValue.name)
		_eventSymbol = State(initialValue: event.wrappedValue.symbol)
		_eventColor = State(initialValue: event.wrappedValue.color.color)
		_eventDescription = State(initialValue: event.wrappedValue.description)
		_eventDate = State(initialValue: event.wrappedValue.date)
		_eventRecurrence = State(initialValue: event.wrappedValue.recurrence)
	}
	
	var body: some View {
//		NavigationStack {
			AddEventView(
				viewModel: viewModel,
				eventName: $eventName,
				eventSymbol: $eventSymbol,
				eventColor: $eventColor,
				eventDescription: $eventDescription,
				eventDate: $eventDate,
				eventRecurrence: $eventRecurrence,
				adding: false //bc we editing existing event
			)
			.navigationTitle("Edit Event")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button() {
						event.name = eventName
						event.symbol = eventSymbol
						event.color = ColorCodable(eventColor)
						event.description = eventDescription
						event.date = eventDate
						event.recurrence = eventRecurrence
						
						//if there is an event in vM.events with the id of the event we r editing,
						//firstindex - loops through the arr and finds first element where that events id matches editing event's id
						if let index = viewModel.events.firstIndex(where: { xEvent in
							xEvent.id == event.id
						}) {
							viewModel.events[index] = event
						}
						viewModel.saveEvents()
						
						dismiss()
					} label: {
						Text("Done")
					}
				}
			}
//		}
	}
}

#Preview {
	EditEventView(
		viewModel: EventViewModel(),
		event: .constant(
			Event(
				name: "Birthday",
				symbol: "gear",
				color: ColorCodable(.red),
				description: "an event",
				date: Date(),
				recurrence: .yearly
			)
		)
	)
}
