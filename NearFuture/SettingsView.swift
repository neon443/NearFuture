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
			ZStack {
				backgroundGradient
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
				.scrollContentBackground(.hidden)
				.navigationTitle("Settings")
				.navigationBarTitleDisplayMode(.inline)
			}
		}
	}
}

#Preview {
	SettingsView(viewModel: dummyEventViewModel())
}

func test() -> Void {
	
}
