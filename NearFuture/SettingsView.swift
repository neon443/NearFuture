//
//  SettingsView.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 29/12/2024.
//

import SwiftUI

struct SettingsView: View {
	@State var viewModel: EventViewModel
	@Binding var showSettings: Bool
	
	var body: some View {
		NavigationStack {
			List {
				Section("Danger Zone") {
					Button("Delete local data", role: .destructive) {
						viewModel.dangerClearLocalData()
					}
					Button("Delete iCloud data", role: .destructive) {
						viewModel.dangerCleariCloudData()
					}
					Button("Delete all data", role: .destructive) {
						viewModel.dangerClearLocalData()
						viewModel.dangerCleariCloudData()
					}
				}
				Section("Debug") {
					Button("Reset UserDefaults", role: .destructive) {
						viewModel.dangerResetLocalData()
					}
					Button("Reset iCloud", role: .destructive) {
						viewModel.dangerResetiCloud()
					}
				}
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button() {
						showSettings.toggle()
					} label: {
						Image(systemName: "xmark.circle.fill")
							.symbolRenderingMode(.hierarchical)
					}
				}
			}
		}
	}
}

#Preview {
	SettingsView(
		viewModel: EventViewModel(),
		showSettings: .constant(true)
	)
}
