//
//  iCloudSettingsView.swift
//  NearFuture
//
//  Created by neon443 on 18/04/2025.
//

import SwiftUI

struct iCloudSettingsView: View {
	@State var viewModel: EventViewModel
	@State var showPushAlert: Bool = false
	@State var showPullAlert: Bool = false
	
	@Binding var hasUbiquitous: Bool
	@Binding var lastSyncWasSuccessful: Bool
	@Binding var lastSyncWasNormalAgo: Bool
	@Binding var localCountEqualToiCloud: Bool
	@Binding var icloudCountEqualToLocal: Bool
	
	let asi = ProcessInfo().isiOSAppOnMac
	let model = UIDevice().model
	var device: (sf: String, label: String) {
		if asi {
			return (sf: "laptopcomputer", label: "Computer")
		} else if model == "iPhone" {
			return (sf: model.lowercased(), label: model)
		} else if model == "iPad" {
			return (sf: model.lowercased(), label: model)
		}
		return (sf: "iphone", label: "iPhone")
	}
	
	var updateStatus: () -> Void
	
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
								Image(systemName: device.sf)
									.resizable()
									.scaledToFit()
									.frame(width: 75, height: 75)
									.symbolRenderingMode(.monochrome)
								Text("\(viewModel.localEventCount)")
									.font(.title2)
									.monospaced()
									.bold()
							}
							Text(device.label)
						}
						Spacer()
					}
					.listRowSeparator(.hidden)
					.onAppear {
						viewModel.sync()
						updateStatus()
					}
					
					HStack {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(hasUbiquitous ? .green : .red)
						Text("iCloud")
						Spacer()
						Text("\(hasUbiquitous ? "" : "Not ")Working")
							.bold()
					}
					
					HStack {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(lastSyncWasSuccessful ? .green : .red)
						Text("Sync Status")
						Spacer()
						Text("\(viewModel.syncStatus)")
							.bold()
					}
					
					HStack {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(lastSyncWasNormalAgo ? .green : .red)
						Text("Last Sync")
						Spacer()
						Text("\(viewModel.lastSync?.formatted(date: .long, time: .standard) ?? "Never")")
							.bold()
					}
					
					HStack {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(localCountEqualToiCloud ? .green : .red)
						Text("Local Events")
						Spacer()
						Text("\(viewModel.localEventCount)")
							.bold()
					}
					
					HStack {
						Circle()
							.frame(width: 20, height: 20)
							.foregroundStyle(icloudCountEqualToLocal ? .green : .red)
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
				updateStatus()
			}
			.scrollContentBackground(.hidden)
			.navigationTitle("iCloud")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview("iCloudSettingsView") {
	iCloudSettingsView(
		viewModel: dummyEventViewModel(),
		hasUbiquitous: .constant(true),
		lastSyncWasSuccessful: .constant(true),
		lastSyncWasNormalAgo: .constant(true),
		localCountEqualToiCloud: .constant(true),
		icloudCountEqualToLocal: .constant(true),
		updateStatus: {}
	)
}
