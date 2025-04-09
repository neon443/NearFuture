//
//  EventListView.swift
//  NearFuture
//
//  Created by neon443 on 30/03/2025.
//

import SwiftUI

struct EventListView: View {
	@ObservedObject var viewModel: EventViewModel
	@State var event: Event
	
	var body: some View {
		NavigationLink() {
			EditEventView(
				viewModel: viewModel,
				event: event
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
						//							.foregroundStyle(
						//								event.complete ? .gray : .primary
						//							)
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

#Preview {
    EventListView(
		viewModel: EventViewModel(),
		event: Event(
			name: "Event",
			complete: false,
			completeDesc: "Coplete notes",
			symbol: "gear",
			color: ColorCodable(.purple),
			notes: "loremd ipsum doret so re mi far",
			date: Date(),
			time: true,
			recurrence: .daily
		)
	)
}
