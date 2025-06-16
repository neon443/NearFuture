//
//  CompleteEventButton.swift
//  NearFuture
//
//  Created by neon443 on 15/06/2025.
//

import SwiftUI

struct CompleteEventButton: View {
	@ObservedObject var viewModel: EventViewModel
	@Binding var event: Event
	
	@State var timer: Timer?
	@State var largeTick: Bool = false
	@State var completeInProgress: Bool = false
	@State var completeStartTime: Date = .now
	@State var progress: Double = 0
	private let completeDuration: TimeInterval = 3.0
	
	var isMac: Bool {
#if canImport(AppKit)
		return true
#else
		return false
#endif
	}
	
	func startCompleting() {
#if canImport(UIKit)
		UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
#endif
		withAnimation { completeInProgress = true }
		completeStartTime = .now
		progress = 0
		
		timer = Timer(timeInterval: 0.02, repeats: true) { timer in
			guard completeInProgress else { return }
			guard timer.isValid else { return }
			let elapsed = Date().timeIntervalSince(completeStartTime)
			progress = min(1, elapsed)
			#if canImport(UIKit)
			UIImpactFeedbackGenerator(style: .light).impactOccurred()
			#endif
			
			if progress >= 1 {
				withAnimation { completeInProgress = false }
				viewModel.completeEvent(&event)
#if canImport(UIKit)
				DispatchQueue.main.asyncAfter(deadline: .now()+0.02) {
					UINotificationFeedbackGenerator().notificationOccurred(.success)
				}
#endif
				timer.invalidate()
				progress = 0
			}
		}
		RunLoop.main.add(timer!, forMode: .common)
	}
	
	var body: some View {
		Group {
			if completeInProgress {
				ZStack {
					CircularProgressView(progress: $progress)
					Image(systemName: "xmark")
						.bold()
				}
				.onTapGesture {
					withAnimation { completeInProgress = false }
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
		.frame(maxWidth: isMac ? 20 : 30)
		.shadow(color: .one.opacity(0.2), radius: 2.5)
		.padding(.trailing, isMac ? 15 : 5)
		.transition(.scale)
		.animation(.spring, value: completeInProgress)
		.animation(
			.spring(response: 0.2, dampingFraction: 0.75, blendDuration: 2),
			value: largeTick
		)
	}
}

struct CircularProgressView: View {
	@Binding var progress: Double
	var body: some View {
		ZStack {
			Circle()
				.stroke(
					.two,
					lineWidth: 5
				)
			Circle()
				.trim(from: 0, to: progress)
				.stroke(
					.one,
					lineWidth: 5
					//					style: StrokeStyle(
					//						lineWidth: 5,
					//						lineCap: .round
					//					)
				)
				.rotationEffect(.degrees(-90))
		}
	}
}

#Preview {
	CompleteEventButton(
		viewModel: dummyEventViewModel(),
		event: .constant(dummyEventViewModel().example)
	)
	.scaleEffect(5)
}

#Preview {
	CircularProgressView(progress: .constant(0.5))
}
