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
			ZStack {
				HStack {
					RoundedRectangle(cornerRadius: 5)
						.frame(width: 7)
						.foregroundStyle(
							event.color.color.opacity(
								event.complete ? 0.5 : 1
							)
						)
					VStack(alignment: .leading) {
						HStack {
							Image(systemName: event.symbol)
								.resizable()
								.scaledToFit()
								.frame(width: 20, height: 20)
								.shadow(radius: 5)
								.foregroundStyle(
									.one.opacity(
										event.complete ? 0.5 : 1
									)
								)
							Text("\(event.name)")
								.font(.headline)
								.foregroundStyle(.one)
								.strikethrough(event.complete)
								.multilineTextAlignment(.leading)
						}
						if !event.notes.isEmpty {
							Text(event.notes)
								.font(.subheadline)
								.foregroundStyle(.one.opacity(0.8))
								.multilineTextAlignment(.leading)
						}
						Text(
							event.date.formatted(
								date: .long,
								time: .shortened
							)
						)
						.font(.subheadline)
						.foregroundStyle(
							.one.opacity(
								event.complete ? 0.5 : 1
							)
						)
						if event.recurrence != .none {
							Text("Occurs \(event.recurrence.rawValue)")
								.font(.subheadline)
								.foregroundStyle(
									.one.opacity(event.complete ? 0.5 : 1))
						}
					}
					Spacer()
					VStack {
						Text("\(daysUntilEvent(event.date).long)")
							.font(.subheadline)
							.foregroundStyle(event.date.timeIntervalSinceNow < 0 ? .red : .one)
							.multilineTextAlignment(.trailing)
					}
					Button() {
						withAnimation {
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
									.bold()
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
					.shadow(radius: 5)
					.padding(.trailing, 5)
					.modifier(hapticSuccess(trigger: event.complete))
				}
				.transition(.opacity)
				.padding(.vertical, 5)
				.overlay(
					RoundedRectangle(cornerRadius: 10)
						.stroke(
							.one.opacity(0.5),
							lineWidth: 1
						)
				)
				.clipShape(
					RoundedRectangle(cornerRadius: 10)
				)
				.fixedSize(horizontal: false, vertical: true)
			}
			.contextMenu() {
				Button(role: .destructive) {
					let eventToModify = viewModel.events.firstIndex() { currEvent in
						currEvent.id == event.id
					}
					if let eventToModify = eventToModify {
						viewModel.events.remove(at: eventToModify)
						viewModel.saveEvents()
					}
				} label: {
					Label("Delete", systemImage: "trash")
				}
			}
		}
	}
}

#Preview("EventListView") {
	let vm = dummyEventViewModel()
	ZStack {
		Color.black
		VStack {
			ForEach(0..<50) { _ in
				Rectangle()
					.foregroundStyle(randomColor().opacity(0.5))
					.padding(-10)
			}
			.ignoresSafeArea(.all)
			.blur(radius: 5)
		}
		VStack {
			ForEach(vm.events) { event in
				EventListView(
					viewModel: vm,
					event: event
				)
			}
		}
		.padding(.horizontal, 10)
	}
}
