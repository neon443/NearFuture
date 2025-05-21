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
		ScrollView {
			ForEach(viewModel.events) { event in
				EventListView(viewModel: viewModel, event: event)
			}
		}
    }
}

#Preview {
	ContentView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}
