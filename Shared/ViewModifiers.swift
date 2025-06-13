//
//  ViewModifiers.swift
//  NearFuture
//
//  Created by neon443 on 13/06/2025.
//

import Foundation
import SwiftUI

struct hapticHeavy: ViewModifier {
	var trigger: any Equatable
	
	init(trigger: any Equatable) {
		self.trigger = trigger
	}
	
	func body(content: Content) -> some View {
		if #available(iOS 17, *) {
			content
				.sensoryFeedback(.impact(weight: .heavy, intensity: 1), trigger: trigger)
		} else {
			content
		}
	}
}

struct hapticSuccess: ViewModifier {
	var trigger: any Equatable
	
	init(trigger: any Equatable) {
		self.trigger = trigger
	}
	
	func body(content: Content) -> some View {
		if #available(iOS 17, *) {
			content.sensoryFeedback(.success, trigger: trigger)
		} else {
			content
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
