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
	
	@State var completeInProgress: Bool = false
	@State var completeStartTime: Date = .now
	@State var progress: Double = 0
	@State var timer: Timer?
	private let completeDuration: TimeInterval = 3.0
	@Environment(\.openWindow) var openWindow
	
	@State var largeTick: Bool = false
	@State var hovering: Bool = false
	
	func startCompleting() {
#if canImport(UIKit)
		UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
#endif
		completeInProgress = true
		progress = 0
		completeStartTime = .now
		
		timer = Timer(timeInterval: 0.01, repeats: true) { timer in
			guard timer.isValid else { return }
			guard completeInProgress else { return }
			let elapsed = Date().timeIntervalSince(completeStartTime)
			progress = min(elapsed, 1.0)
			
			if progress >= 1.0 {
				timer.invalidate()
				viewModel.completeEvent(&event)
#if canImport(UIKit)
				UINotificationFeedbackGenerator().notificationOccurred(.success)
#endif
				completeInProgress = false
			}
		}
		RunLoop.main.add(timer!, forMode: .common)
	}
	
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
				
				Group {
					if completeInProgress {
						ZStack {
							ProgressView(value: progress)
								.progressViewStyle(.circular)
							Image(systemName: "xmark")
								.bold()
						}
						.onTapGesture {
							timer?.invalidate()
							completeInProgress = false
							progress = 0
						}
					} else {
						Image(systemName: event.complete ? "checkmark.circle.fill" : "circle")
							.resizable().scaledToFit()
							.foregroundStyle(event.complete ? .green : event.color.color)
							.bold()
							.onTapGesture {
								startCompleting()
							}
							.onHover() { hovering in
								withAnimation {
									largeTick.toggle()
								}
							}
							.scaleEffect(largeTick ? 1.5 : 1)
					}
				}
				.frame(maxWidth: 20)
				.shadow(color: .one.opacity(0.2), radius: 2.5)
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
	#else
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
						startCompleting()
					} label: {
						if completeInProgress {
							ZStack {
								ProgressView(value: progress)
									.progressViewStyle(.circular)
								Image(systemName: "xmark")
									.bold()
							}
							.onTapGesture {
								timer?.invalidate()
								completeInProgress = false
								progress = 0
							}
						} else {
							Image(systemName: event.complete ? "checkmark.circle.fill" : "circle")
								.resizable().scaledToFit()
								.foregroundStyle(event.complete ? .green : event.color.color)
								.bold()
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
