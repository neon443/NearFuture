//
//  ViewModifiers.swift
//  NearFuture
//
//  Created by neon443 on 13/06/2025.
//

import Foundation
import SwiftUI

extension View {
	func hapticHeavy(trigger: any Equatable) -> some View {
		if #available(iOS 17, *) {
			self.modifier(sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: trigger)) as! Self
		} else {
			self
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

extension View {
	func hapticSucess(trigger: any Equatable) -> some View {
		if #available(iOS 17, *) {
			self.modifier(sensoryFeedback(.success, trigger: trigger)) as! Self
		} else {
			self
		}
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
