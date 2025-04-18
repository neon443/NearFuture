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
	@State private var eventComplete: Bool
	@State private var eventCompleteDesc: String
	@State private var eventSymbol: String
	@State private var eventColor: Color
	@State private var eventNotes: String
	@State private var eventDate: Date
	@State private var eventTime: Bool
	@State private var eventRecurrence: Event.RecurrenceType
	
	init(viewModel: EventViewModel, event: Binding<Event>) {
		self.viewModel = viewModel
		_event = event
		_eventName = State(initialValue: event.wrappedValue.name)
		_eventComplete = State(initialValue: event.wrappedValue.complete)
		_eventCompleteDesc = State(initialValue: event.wrappedValue.completeDesc)
		_eventSymbol = State(initialValue: event.wrappedValue.symbol)
		_eventColor = State(initialValue: event.wrappedValue.color.color)
		_eventNotes = State(initialValue: event.wrappedValue.notes)
		_eventDate = State(initialValue: event.wrappedValue.date)
		_eventTime = State(initialValue: event.wrappedValue.time)
		_eventRecurrence = State(initialValue: event.wrappedValue.recurrence)
	}
	
	fileprivate func saveEdits() {
		event.name = eventName
		event.symbol = eventSymbol
		event.color = ColorCodable(eventColor)
		event.notes = eventNotes
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
	}
	
	var body: some View {
		AddEventView(
			viewModel: viewModel,
			eventName: $eventName,
			eventComplete: $eventComplete,
			eventCompleteDesc: $eventCompleteDesc,
			eventSymbol: $eventSymbol,
			eventColor: $eventColor,
			eventNotes: $eventNotes,
			eventDate: $eventDate,
			eventTime: $eventTime,
			eventRecurrence: $eventRecurrence,
			adding: false //bc we editing existing event
		)
		.navigationTitle("Edit Event")
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button() {
					saveEdits()
				} label: {
					Text("Done")
				}
				.disabled(eventName == "")
			}
		}
	}
}

#Preview {
	EditEventView(
		viewModel: EventViewModel(),
		event: .constant(
			EventViewModel().example
		)
	)
}
