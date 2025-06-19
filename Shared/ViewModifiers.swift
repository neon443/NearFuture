//
//  ViewModifiers.swift
//  NearFuture
//
//  Created by neon443 on 13/06/2025.
//

import Foundation
import SwiftUI

struct hapticHeavy<T: Equatable>: ViewModifier {
	var trigger: T
	
	init(trigger: T) {
		self.trigger = trigger
	}
	
	func body(content: Content) -> some View {
		content
			.onChange(of: trigger) { _ in
				#if canImport(UIKit)
				UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
				#endif
			}
	}
}

struct hapticSuccess<T: Equatable>: ViewModifier {
	var trigger: T
	
	init(trigger: T) {
		self.trigger = trigger
	}
	
	func body(content: Content) -> some View {
		content
			.onChange(of: trigger) { _ in
				#if canImport(UIKit)
				UINotificationFeedbackGenerator().notificationOccurred(.success)
				#endif
			}
	}
}

struct glassButton: ViewModifier {
	func body(content: Content) -> some View {
#if swift(>=6.2)
		content.buttonStyle(.glass)
#else
		content.buttonStyle(.borderedProminent)
			.clipShape(RoundedRectangle(cornerRadius: 15))
			.tint(.two)
#endif
	}
}

struct navigationInlineLarge: ViewModifier {
	func body(content: Content) -> some View {
#if os(macOS)
		content
			.toolbarTitleDisplayMode(.inlineLarge)
#else
		content
			.navigationBarTitleDisplayMode(.inline)
#endif
	}
}

struct presentationSizeForm: ViewModifier {
	func body(content: Content) -> some View {
		if #available(iOS 18, macOS 15, *) {
			content.presentationSizing(.form)
		} else {
			content
		}
	}
}
