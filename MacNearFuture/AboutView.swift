//
//  AboutView.swift
//  MacNearFuture
//
//  Created by neon443 on 28/05/2025.
//

import SwiftUI

struct AboutView: View {
	var body: some View {
		VStack(alignment: .center) {
			Image(nsImage: #imageLiteral(resourceName: "NearFutureIcon.png"))
				.resizable()
				.scaledToFit()
				.frame(width: 100)
				.clipShape(RoundedRectangle(cornerRadius: 25))
			Text("Near Future")
				.bold()
				.monospaced()
				.font(.title)
			Text("Version " + getVersion() + " (\(getBuildID()))")
				.padding(.bottom)
			Text("© 2024-2025 neon443, Inc")
				.padding(.bottom)
			Link("Developer Website", destination: URL(string: "https://neon443.xyz")!)
		}
		.padding()
		.padding()
		.containerBackground(.ultraThinMaterial, for: .window)
		.toolbar(removing: .title)
		.toolbarBackground(.hidden, for: .windowToolbar)
		.windowMinimizeBehavior(.disabled)
		.windowFullScreenBehavior(.disabled)
	}
}

#Preview {
    AboutView()
}
