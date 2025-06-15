//
//  SettingsView.swift
//  NearFuture
//
//  Created by neon443 on 13/06/2025.
//

import SwiftUI

struct SettingsView: View {
	@ObservedObject var viewModel: EventViewModel
	@ObservedObject var settingsModel: SettingsViewModel
	
	@State private var importStr: String = ""
	
	func changeIcon(to toIcon: String) {
		if let nsimage = NSImage(named: toIcon) {
			let nsImageView = NSImageView(image: nsimage)
			nsImageView.frame = NSRect(x: 0, y: 0, width: 128, height: 128)
			NSApplication.shared.dockTile.contentView = nsImageView
			NSApplication.shared.dockTile.display()
		}
	}
	
	var body: some View {
		NavigationStack {
			List {
				ScrollView(.horizontal) {
					HStack {
						ForEach(settingsModel.accentChoices, id: \.self) { choice in
							let color = Color(nsColor: NSColor(named: "uiColors/\(choice)")!)
							ZStack {
								Button() {
									settingsModel.changeTint(to: choice)
									changeIcon(to: choice)
								} label: {
									Circle()
										.foregroundStyle(color)
										.frame(width: 30)
								}
								.buttonStyle(.plain)
								if ColorCodable(color) == settingsModel.settings.tint {
									let needContrast: Bool = ColorCodable(color) == settingsModel.settings.tint
									Circle()
										.foregroundStyle(needContrast ? .two : .one)
										.frame(width: 10)
								}
							}
						}
					}
				}
				Button("Show What's New") {
					settingsModel.settings.showWhatsNew = true
				}
				Toggle("Show completed Events in Home", isOn: $settingsModel.settings.showCompletedInHome)
					.onChange(of: settingsModel.settings.showCompletedInHome) { _ in
						settingsModel.saveSettings()
					}
				NavigationLink() {
					List {
						if !settingsModel.notifsGranted {
							Text("\(Image(systemName: "xmark")) Notifications disabled for Near Future")
								.foregroundStyle(.red)
							Button("Request Notifications") {
								Task.detached {
									let requestNotifsResult = await requestNotifs()
									await MainActor.run {
										settingsModel.notifsGranted = requestNotifsResult
									}
								}
							}
						} else {
							Text("\(Image(systemName: "checkmark")) Notifications enabled for Near Future")
								.foregroundStyle(.green)
						}
					}
				} label: {
					Image(systemName: "bell.badge.fill")
					Text("Notifications")
				}
				NavigationLink() {
					iCloudSettingsView(
						viewModel: viewModel,
						settingsModel: settingsModel
					)
				} label: {
					HStack {
						Image(systemName: "icloud.fill")
						Text("iCloud")
						Spacer()
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(viewModel.iCloudStatusColor)
					}
				}
				.onAppear {
					viewModel.sync()
					viewModel.updateiCStatus()
				}
				NavigationLink() {
					ImportView(viewModel: viewModel, importStr: $importStr)
				} label: {
					Label("Import Events", systemImage: "tray.and.arrow.down.fill")
						.foregroundStyle(.one)
				}
				NavigationLink() {
					ExportView(viewModel: viewModel)
				} label: {
					Label("Export Events", systemImage: "square.and.arrow.up")
						.foregroundStyle(.one)
				}
				
				Text("Tip")
					.font(.subheadline)
				Text("Near Future has Widgets!")
				
				Text("Danger Zone")
					.foregroundStyle(.red)
					.font(.subheadline)
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
				
				Text("Debug")
					.foregroundStyle(.red)
					.font(.subheadline)
				Button("Reset UserDefaults", role: .destructive) {
					viewModel.dangerResetLocalData()
				}
				Button("Reset iCloud", role: .destructive) {
					viewModel.dangerResetiCloud()
				}
				
				//			AboutView()
				
				.modifier(navigationInlineLarge())
				.scrollContentBackground(.hidden)
			}
		}
	}
}

#Preview {
	SettingsView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}
