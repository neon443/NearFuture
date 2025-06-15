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
	
	@Environment(\.openWindow) var openWindow
	
	@State var hovering: Bool = false
	
#if canImport(AppKit)
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
				CompleteEventButton(
					viewModel: viewModel,
					event: $event
				)
			}
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
#else
	var body: some View {
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
			CompleteEventButton(
				viewModel: viewModel,
				event: $event
			)
		}
		.padding(.vertical, 5)
		.overlay(
			RoundedRectangle(cornerRadius: 15)
				.stroke(.one.opacity(0.5), lineWidth: 1)
		)
		.clipShape(RoundedRectangle(cornerRadius: 15))
		.fixedSize(horizontal: false, vertical: true)
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
#endif
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
