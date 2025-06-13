//
//  EventListView.swift
//  MacNearFuture
//
//  Created by neon443 on 21/05/2025.
//

import SwiftUI

struct EventListView: View {
	@ObservedObject var viewModel: EventViewModel
	@State var event: Event
	
	@State var largeTick: Bool = false
	@State var hovering: Bool = false
	
	@Environment(\.openWindow) var openWindow
	
	var body: some View {
		ZStack {
			Color.black.opacity(hovering ? 0.5 : 0.0)
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
							.bold()
							.foregroundStyle(.one)
							.strikethrough(event.complete)
							.multilineTextAlignment(.leading)
					}
					if !event.notes.isEmpty {
						Text(event.notes)
							.foregroundStyle(.one.opacity(0.8))
							.multilineTextAlignment(.leading)
					}
					Text(
						event.date.formatted(
							date: .long,
							time: .shortened
						)
					)
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
						.multilineTextAlignment(.trailing)
						.foregroundStyle(event.date.timeIntervalSinceNow < 0 ? .red : .one)
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
				.onHover() { hovering in
					withAnimation {
						largeTick.toggle()
					}
				}
				.buttonStyle(.borderless)
				.scaleEffect(largeTick ? 1.5 : 1)
				.frame(maxWidth: 20)
				.shadow(radius: 5)
				.padding(.trailing, 15)
				.animation(
					.spring(response: 0.2, dampingFraction: 0.75, blendDuration: 2),
					value: largeTick
				)
			}
			.transition(.opacity)
			.fixedSize(horizontal: false, vertical: true)
		}
		.onHover { isHovering in
			withAnimation {
				hovering.toggle()
			}
		}
		.onTapGesture {
			openWindow(value: event.id)
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


#Preview {
	EventListView(
		viewModel: dummyEventViewModel(),
		event: dummyEventViewModel().template
	)
}
