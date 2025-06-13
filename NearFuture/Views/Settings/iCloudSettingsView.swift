//
//  iCloudSettingsView.swift
//  NearFuture
//
//  Created by neon443 on 18/04/2025.
//

import SwiftUI

struct iCloudSettingsView: View {
	@ObservedObject var viewModel: EventViewModel
	@ObservedObject var settingsModel: SettingsViewModel
	@State var showPushAlert: Bool = false
	@State var showPullAlert: Bool = false
	
//	@Binding var hasUbiquitous: Bool
//	@Binding var lastSyncWasSuccessful: Bool
//	@Binding var lastSyncWasNormalAgo: Bool
//	@Binding var localCountEqualToiCloud: Bool
//	@Binding var icloudCountEqualToLocal: Bool
//	
//	var updateStatus: () -> Void
	
	var body: some View {
		ZStack {
			backgroundGradient
			List {
				Section {
					HStack {
						Spacer()
						VStack {
							ZStack {
								Image(systemName: "icloud")
									.resizable()
									.scaledToFit()
									.frame(width: 75, height: 55)
									.symbolRenderingMode(.multicolor)
								Text("\(viewModel.icloudEventCount)")
									.font(.title2)
									.monospaced()
									.bold()
							}
							Text("iCloud")
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
										viewModel.updateiCStatus()
									}
									Button("Cancel", role: .cancel) {}
								} message: {
									Text("This will replace Events stored in iCloud with Events stored locally.")
								}
								
								Button() {
									viewModel.sync()
									viewModel.updateiCStatus()
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
										viewModel.updateiCStatus()
									}
									Button("Cancel", role: .cancel) {}
								} message: {
									Text("This will replace Events stored locally with Events stored in iCloud.")
								}
							}
							ZStack {
								Image(systemName: settingsModel.device.sf)
									.resizable()
									.scaledToFit()
									.frame(width: 75, height: 75)
									.symbolRenderingMode(.monochrome)
								Text("\(viewModel.localEventCount)")
									.font(.title2)
									.monospaced()
									.bold()
							}
							Text(settingsModel.device.label)
						}
						Spacer()
					}
					.listRowSeparator(.hidden)
					.onAppear {
						viewModel.sync()
						viewModel.updateiCStatus()
					}
					
					HStack {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(viewModel.hasUbiquitous ? .green : .red)
						Text("iCloud")
						Spacer()
						Text("\(viewModel.hasUbiquitous ? "" : "Not ")Working")
							.bold()
					}
					
					HStack {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(viewModel.lastSyncWasSuccessful ? .green : .red)
						Text("Sync Status")
						Spacer()
						Text("\(viewModel.syncStatus)")
							.bold()
					}
					
					HStack {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(viewModel.lastSyncWasNormalAgo ? .green : .red)
						Text("Last Sync")
						Spacer()
						Text("\(viewModel.lastSync?.formatted(date: .long, time: .standard) ?? "Never")")
							.bold()
					}
					
					HStack {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(viewModel.localCountEqualToiCloud ? .green : .red)
						Text("Local Events")
						Spacer()
						Text("\(viewModel.localEventCount)")
							.bold()
					}
					
					HStack {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(viewModel.icloudCountEqualToLocal ? .green : .red)
						Text("Events in iCloud")
						Spacer()
						Text("\(viewModel.icloudEventCount)")
							.bold()
					}
				} header: {
					Text("Sync Status")
				} footer: {
					Text("Pull to sync\nOr use the arrows to force push/pull")
				}
			}
			.refreshable {
				viewModel.sync()
				viewModel.updateiCStatus()
			}
			.scrollContentBackground(.hidden)
			.navigationTitle("iCloud")
		}
	}
}

#Preview("iCloudSettingsView") {
	iCloudSettingsView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}
