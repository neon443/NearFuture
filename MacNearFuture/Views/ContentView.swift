//
//  ContentView.swift
//  MacNearFuture
//
//  Created by neon443 on 21/05/2025.
//

import SwiftUI

struct ContentView: View {
	@ObservedObject var viewModel: EventViewModel
	@ObservedObject var settingsModel: SettingsViewModel
	
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
			Text(getVersion())
				.foregroundStyle(Color("uiColors/bloo"))
        }
        .padding()
    }
}

#Preview {
	ContentView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}
