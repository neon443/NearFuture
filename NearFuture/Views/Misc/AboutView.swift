//
//  AboutView.swift
//  NearFuture
//
//  Created by neon443 on 12/05/2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
		VStack {
			Image(uiImage: #imageLiteral(resourceName: "NearFutureIcon.png"))
				.resizable()
				.scaledToFit()
				.frame(width: 100)
				.clipShape(RoundedRectangle(cornerRadius: 25))
			Text("Near Future")
				.bold()
				.monospaced()
				.font(.title)
				.frame(maxWidth: .infinity)
			Text("Version " + getVersion() + " (\(getBuildID()))")
				.frame(maxWidth: .infinity)
		}
    }
}

#Preview {
    AboutView()
}
