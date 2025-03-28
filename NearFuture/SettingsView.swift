//
//  SettingsView.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 29/12/2024.
//

import SwiftUI

struct SettingsView: View {
	@State var viewModel: EventViewModel
	
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
	
	var body: some View {
		NavigationStack {
			List {
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
					NavigationStack() {
						Button() {
							UIPasteboard.general.string = "\(viewModel.exportEvents() ?? "")"
							print(viewModel.exportEvents() as Any)
						} label: {
							Text("copy")
						}
						Text("\(viewModel.exportEvents() ?? "")")
					}
				} label: {
					Image(systemName: "list.bullet.rectangle")
					Text("Export events")
				}
				NavigationLink() {
					NavigationStack() {
						VStack {
							TextEditor(text: $importStr)
								.foregroundStyle(.foreground, .gray)
								.background(.gray)
								.frame(width: 200, height: 400)
								.shadow(radius: 5)
							Button() {
								viewModel.importEvents(importStr)
							} label: {
								Text("import events")
							}
							.buttonStyle(BorderedProminentButtonStyle())
							Button() {
								if let pb = UIPasteboard.general.string {
									print(pb)
								}
							} label: {
								Text("print pb")
							}
						}
					}
				} label: {
					Image(systemName: "square.and.arrow.down")
					Text("Import events")
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
			}
			.navigationTitle("Settings")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

struct iCloudSettingsView: View {
	@State var viewModel: EventViewModel
	@State var showPushAlert: Bool = false
	@State var showPullAlert: Bool = false
	
	@Binding var hasUbiquitous: Bool
	@Binding var lastSyncWasSuccessful: Bool
	@Binding var lastSyncWasNormalAgo: Bool
	@Binding var localCountEqualToiCloud: Bool
	@Binding var icloudCountEqualToLocal: Bool
	
	var updateStatus: () -> Void
	
	var body: some View {
		List {
			HStack {
				Spacer()
				VStack {
					ZStack {
						Image(systemName: "icloud")
							.resizable()
							.scaledToFit()
							.frame(width: 75, height: 75)
							.symbolRenderingMode(.multicolor)
						Text("\(viewModel.icloudEventCount)")
							.font(.title2)
					}
					HStack {
						Button(role: .destructive) {
							showPushAlert.toggle()
						} label: {
							Image(systemName: "arrow.up")
								.resizable()
								.scaledToFit()
								.frame(width: 30, height: 40)
						}
						.buttonStyle(BorderedButtonStyle())
						.alert("Warning", isPresented: $showPushAlert) {
							Button("OK", role: .destructive) {
								viewModel.replaceiCloudWithLocalData()
								viewModel.sync()
								updateStatus()
							}
							Button("Cancel", role: .cancel) {}
						} message: {
							Text("This will replace Events stored in iCloud with Events stored locally.")
						}

						Button() {
							viewModel.sync()
							updateStatus()
						} label: {
							Image(systemName: "arrow.triangle.2.circlepath")
								.resizable()
								.scaledToFit()
								.frame(width: 30, height: 40)
								.foregroundStyle(Color.accentColor)
						}
						.buttonStyle(BorderedButtonStyle())
						
						Button(role: .destructive) {
							showPullAlert.toggle()
						} label: {
							Image(systemName: "arrow.down")
								.resizable()
								.scaledToFit()
								.frame(width: 30, height: 40)
						}
						.buttonStyle(BorderedButtonStyle())
						.alert("Warning", isPresented: $showPullAlert) {
							Button("OK", role: .destructive) {
								viewModel.replaceLocalWithiCloudData()
								viewModel.sync()
								updateStatus()
							}
							Button("Cancel", role: .cancel) {}
						} message: {
							Text("This will replace Events stored locally with Events stored in iCloud.")
						}
					}
					ZStack {
						Image(systemName: "iphone.gen3")
							.resizable()
							.scaledToFit()
							.frame(width: 75, height: 75)
							.symbolRenderingMode(.monochrome)
						Text("\(viewModel.localEventCount)")
							.font(.headline)
					}
				}
				Spacer()
			}
			.onAppear {
				viewModel.sync()
				updateStatus()
			}
			
			HStack {
				Circle()
					.frame(width: 20, height: 20)
					.foregroundStyle(hasUbiquitous ? .green : .red)
				Text("iCloud Key Value Store:")
				Text("\(hasUbiquitous ? "" : "Not ")Working")
					.bold()
			}
			
			HStack {
				Circle()
					.frame(width: 20, height: 20)
					.foregroundStyle(lastSyncWasSuccessful ? .green : .red)
				Text("Sync Status:")
				Text("\(viewModel.syncStatus)")
					.bold()
			}
			
			HStack {
				Circle()
					.frame(width: 20, height: 20)
					.foregroundStyle(lastSyncWasNormalAgo ? .green : .red)
				Text("Last Sync:")
				Text("\(viewModel.lastSync?.formatted() ?? "Never")")
					.bold()
			}
			
			HStack {
				Circle()
					.frame(width: 20, height: 20)
					.foregroundStyle(localCountEqualToiCloud ? .green : .red)
				Text("\(viewModel.localEventCount)")
					.bold()
				Text("Local Events")
			}
			
			HStack {
				Circle()
					.frame(width: 20, height: 20)
					.foregroundStyle(icloudCountEqualToLocal ? .green : .red)
				Text("\(viewModel.icloudEventCount)")
					.bold()
				Text("Events in iCloud")
			}
		}
		.navigationTitle("iCloud")
		.navigationBarTitleDisplayMode(.inline)
	}
}

#Preview {
	SettingsView(
		viewModel: EventViewModel()
	)
}

#Preview("iCloudSettingsView") {
	iCloudSettingsView(
		viewModel: EventViewModel(),
		hasUbiquitous: .constant(true),
		lastSyncWasSuccessful: .constant(true),
		lastSyncWasNormalAgo: .constant(true),
		localCountEqualToiCloud: .constant(true),
		icloudCountEqualToLocal: .constant(true),
		updateStatus: test
	)
}

func test() -> Void {
	
}
