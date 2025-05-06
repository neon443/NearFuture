//
//  SettingsView.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 29/12/2024.
//

import SwiftUI

struct SettingsView: View {
	@ObservedObject var viewModel: EventViewModel
	@ObservedObject var settingsModel: SettingsViewModel
	
	@State private var hasUbiquitous: Bool = false
	@State private var lastSyncWasSuccessful: Bool = false
	@State private var lastSyncWasNormalAgo: Bool = false
	@State private var localCountEqualToiCloud: Bool = false
	@State private var icloudCountEqualToLocal: Bool = false
	@State private var importStr: String = ""
	
	func updateStatus() {
		let vm = viewModel
		hasUbiquitous = vm.hasUbiquitousKeyValueStore()
		lastSyncWasSuccessful = vm.syncStatus.contains("Success")
		lastSyncWasNormalAgo = vm.lastSync?.timeIntervalSinceNow.isNormal ?? false
		localCountEqualToiCloud = vm.localEventCount == vm.icloudEventCount
		icloudCountEqualToLocal = vm.icloudEventCount == vm.localEventCount
	}
	
	var iCloudStatusColor: Color {
		let allTrue = hasUbiquitous && lastSyncWasSuccessful && lastSyncWasNormalAgo && localCountEqualToiCloud && icloudCountEqualToLocal
		let someTrue = hasUbiquitous || lastSyncWasSuccessful || lastSyncWasNormalAgo || localCountEqualToiCloud || icloudCountEqualToLocal
		
		if allTrue {
			return .green
		} else if someTrue {
			return .orange
		} else {
			return .red
		}
	}
	let rainbow: [Color] = [
		Color.UiColors.red,
		Color.UiColors.orange,
		Color.UiColors.yellow,
		Color.UiColors.green,
		Color.UiColors.blue,
		Color.UiColors.indigo,
		Color.UiColors.basic
	]
	@State private var selectedIndex: Int = 1
	
	var body: some View {
		NavigationStack {
			ZStack {
				backgroundGradient
				List {
					ScrollView(.horizontal) {
						HStack {
							ForEach(0..<rainbow.count, id: \.self) { index in
								ZStack {
									Button() {
										selectedIndex = index
										settingsModel.settings.tint.colorBind = rainbow[index]
										settingsModel.saveSettings()
									} label: {
										Circle()
											.foregroundStyle(rainbow[index])
											.frame(width: 30)
									}
									if selectedIndex == index {
										Circle()
											.foregroundStyle(index == rainbow.count-1 ? .two : .one)
											.frame(width: 10)
									}
								}
							}
						}
					}
					NavigationLink() {
						iCloudSettingsView(
							viewModel: viewModel,
							hasUbiquitous: $hasUbiquitous,
							lastSyncWasSuccessful: $lastSyncWasSuccessful,
							lastSyncWasNormalAgo: $lastSyncWasNormalAgo,
							localCountEqualToiCloud: $localCountEqualToiCloud,
							icloudCountEqualToLocal: $icloudCountEqualToLocal,
							updateStatus: updateStatus
						)
					} label: {
						HStack {
							Image(systemName: "icloud.fill")
							Text("iCloud")
							Spacer()
							Circle()
								.frame(width: 20, height: 20)
								.foregroundStyle(iCloudStatusColor)
						}
					}
					.onAppear {
						viewModel.sync()
						updateStatus()
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
					
					Section("Tip") {
						Text("Near Future has Widgets!")
					}
					
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
					Section("About") {
						VStack {
							if let image = UIImage(named: getAppIcon()) {
								Image(uiImage: image)
									.resizable()
									.scaledToFit()
									.frame(width: 100)
									.clipShape(RoundedRectangle(cornerRadius: 25))
							}
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
			}
			.scrollContentBackground(.hidden)
			.navigationTitle("Settings")
			.apply {
				if #available(iOS 17, *) {
					$0.toolbarTitleDisplayMode(.inlineLarge)
				} else {
					$0.navigationBarTitleDisplayMode(.inline)
				}
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

func getAppIcon() -> String {
	let bundle = Bundle.main
	guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
		  let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
		  let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
		  let iconFileName = iconFiles.last else {
		fatalError("hell na where ur icon")
	}
	return iconFileName
}

func getVersion() -> String {
	guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] else {
		fatalError("no bundle id wtf lol")
	}
	return "\(version)"
}

func getBuildID() -> String {
	guard let build = Bundle.main.infoDictionary?["CFBundleVersion"] else {
		fatalError("wtf did u do w the build number")
	}
	return "\(build)"
}
