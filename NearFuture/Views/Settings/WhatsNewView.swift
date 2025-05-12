//
//  WhatsNewView.swift
//  NearFuture
//
//  Created by neon443 on 12/05/2025.
//

import SwiftUI

struct WhatsNewView: View {
	@ObservedObject var settingsModel: SettingsViewModel
	@Environment(\.dismiss) var dismiss
	struct WhatsNew: Identifiable {
		var id: UUID = UUID()
		var symbol: String
		var title: String
		var subtitle: String
	}
	var whatsNew: [WhatsNew] {
		return [
			WhatsNew(
				symbol: settingsModel.device.sf,
				title: "This Screen",
				subtitle: "This update add a Whats New page that will tell you (suprise!) What's New"
			),
			WhatsNew(
				symbol: "bell.badge.fill",
				title: "Notifications",
				subtitle: "Events now have notifications, reminding you to complete them!"
			),
			WhatsNew(
				symbol: "list.bullet.indent",
				title: "Animations!",
				subtitle: "I added animations for adding, removing and ticking events"
			)
		]
	}
	var body: some View {
		NavigationStack {
			List {
				VStack {
					Text("What's New")
						.font(.largeTitle)
						.bold()
					AboutView()
					Divider()
					ForEach(whatsNew) { new in
						WhatsNewChunk(
							symbol: new.symbol,
							title: new.title,
							subtitle: new.subtitle
						)
					}
						
				}
				.onDisappear {
					settingsModel.settings.showWhatsNew = false
					settingsModel.saveSettings()
				}
			}
			Button() {
				dismiss()
			} label: {
				Text("Continue")
					.font(.headline)
					.frame(height: 40)
					.bold()
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(BorderedProminentButtonStyle())
			.clipShape(RoundedRectangle(cornerRadius: 15))
			.padding().padding()
		}
		.scrollContentBackground(.hidden)
		.presentationDragIndicator(.visible)
		.apply {
			if #available(iOS 16.4, *) {
				$0.presentationBackground(.ultraThinMaterial)
			}
		}
	}
}

#Preview {
	Color.accent
		.ignoresSafeArea(.all)
		.sheet(isPresented: .constant(true)) {
			WhatsNewView(settingsModel: dummySettingsViewModel())
		}
}

struct WhatsNewChunk: View {
	@State var symbol: String
	@State var title: String
	@State var subtitle: String
	var body: some View {
//		GeometryReader { geo in
			HStack {
				Image(systemName: symbol)
					.resizable()
					.scaledToFit()
					.frame(width: 30, height: 30)
					.foregroundStyle(.accent)
					.padding(.trailing, 5)
				VStack(alignment: .leading) {
					Text(title)
						.font(.headline)
						.bold()
					Text(subtitle)
						.foregroundStyle(.gray)
						.font(.subheadline)
				}
			}
//		}
	}
}
