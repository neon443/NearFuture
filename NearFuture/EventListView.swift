//
//  EventListView.swift
//  NearFuture
//
//  Created by neon443 on 18/04/2025.
//

import SwiftUI
import SwiftData

struct EventListView: View {
	@ObservedObject var viewModel: EventViewModel
	@State var event: Event
	
	var body: some View {
		NavigationLink() {
			EditEventView(
				viewModel: viewModel,
				event: $event
			)
		} label: {
			HStack {
				RoundedRectangle(cornerRadius: 5)
					.frame(width: 5)
					.foregroundStyle(
						event.color.color.opacity(
							event.complete ? 0.5 : 1
						)
					)
					.padding(.leading, -10)
					.padding(.vertical, 5)
					.animation(.spring, value: event.complete)
				VStack(alignment: .leading) {
					HStack {
						Image(systemName: event.symbol)
							.resizable()
							.scaledToFit()
							.frame(width: 20, height: 20)
							.foregroundStyle(
								event.color.color.opacity(
									event.complete ? 0.5 : 1
								)
							)
							.animation(.spring, value: event.complete)
						Text("\(event.name)")
							.font(.headline)
							.strikethrough(event.complete)
							.animation(.spring, value: event.complete)
					}
					if !event.notes.isEmpty {
						Text(event.notes)
							.font(.subheadline)
							.foregroundColor(.gray)
					}
					Text(
						event.date.formatted(
							date: .long,
							time: event.time ? .standard : .omitted
						)
					)
					.font(.subheadline)
					.foregroundStyle(
						event.color.color.opacity(
							event.complete ? 0.5 : 1
						)
					)
					.animation(.spring, value: event.complete)
					if event.recurrence != .none {
						Text("Recurs \(event.recurrence.rawValue)")
							.font(.subheadline)
							.foregroundStyle(
								.primary.opacity(
									event.complete ? 0.5 : 1
								)
							)
							.animation(.spring, value: event.complete)
					}
				}
				
				Spacer()
				
				VStack {
					Text("\(daysUntilEvent(event.date, short: false))")
						.font(.subheadline)
						.foregroundStyle(
							event.color.color.opacity(
								event.complete ? 0.5 : 1
							)
						)
						.animation(.spring, value: event.complete)
				}
				Button() {
					withAnimation(.spring) {
						event.complete.toggle()
					}
					let eventToModify = viewModel.events.firstIndex() { currEvent in
						currEvent.id == event.id
					}
					if let eventToModify = eventToModify {
						viewModel.events[eventToModify] = event
						viewModel.saveEvents()
						viewModel.loadEvents()
					}
				} label: {
					if event.complete {
						ZStack {
							Circle()
								.foregroundStyle(.green)
							Image(systemName: "checkmark")
								.resizable()
								.foregroundStyle(.white)
								.scaledToFit()
								.frame(width: 15)
						}
					} else {
						Image(systemName: "circle")
							.resizable()
							.scaledToFit()
							.foregroundStyle(event.color.color)
					}
				}
				.buttonStyle(.borderless)
				.frame(maxWidth: 25, maxHeight: 25)
				.animation(.spring, value: event.complete)
			}
		}
	}
}

#Preview("EventListView") {
	EventListView(
		viewModel: EventViewModel(),
		event:
			EventViewModel().example
	)
}
