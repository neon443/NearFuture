//
//  Extension.swift
//  NearFuture
//
//  Created by neon443 on 21/05/2025.
//

import Foundation
import SwiftUI

extension View {
	var backgroundGradient: some View {
		return LinearGradient(
			gradient: Gradient(colors: [.bgTop, .two]),
			startPoint: .top,
			endPoint: .bottom
		)
		.ignoresSafeArea(.all)
	}
	
	func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}

extension AnyTransition {
	static var moveAndFade: AnyTransition {
		.asymmetric(
			insertion: .move(edge: .leading),
			removal: .move(edge: .trailing)
		)
		.combined(with: .opacity)
	}
	static var moveAndFadeReversed: AnyTransition {
		.asymmetric(
			insertion: .move(edge: .trailing),
			removal: .move(edge: .leading)
		)
		.combined(with: .opacity)
	}
}
