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
	struct WhatsNewChunk: Identifiable {
		var id: UUID = UUID()
		var symbol: String
		var title: String
		var subtitle: String
	}
	@State var bye: Bool = false
	var whatsNewChunks: [WhatsNewChunk] {
		return [
			WhatsNewChunk(
				symbol: "desktopcomputer",
				title: "Mac Native App",
				subtitle: "New Mac native app (Intel too!)"
			),
			WhatsNewChunk(
				symbol: "iphone.radiowaves.left.and.right",
				title: "Haptic Feedback",
				subtitle: "Lovely haptic feedback when completing and adding events, and selecting tabs"
			),
			WhatsNewChunk(
				symbol: "app",
				title: "App Icons",
				subtitle: "You now get a special app icon that matches the color you choose in settings!"
			),
			WhatsNewChunk(
				symbol: "apps.iphone",
				title: "Widgets Day Count Fix",
				subtitle: "The day count for widgets are now red for overdue events, just like the app, and are now more readable"
			),
			WhatsNewChunk(
				symbol: settingsModel.device.sf,
				title: "This Screen",
				subtitle: "This update add a Whats New page that will tell you (suprise!) What's New"
			),
			WhatsNewChunk(
				symbol: "bell.badge.fill",
				title: "Notifications",
				subtitle: "Events now have notifications, reminding you to complete them!"
			),
			WhatsNewChunk(
				symbol: "list.bullet.indent",
				title: "Animations!",
				subtitle: "I added animations for adding, removing and ticking events - animations are definitely the most important change"
			)
		]
	}
	var body: some View {
		NavigationStack {
			ScrollView {
				Text("What's New")
					.font(.largeTitle)
					.bold()
					.padding(.vertical)
				VStack(alignment: .leading) {
					ForEach(whatsNewChunks) { new in
						WhatsNewChunkView(
							symbol: new.symbol,
							title: new.title,
							subtitle: new.subtitle
						)
					}
					Spacer()
				}
				.padding(.horizontal, 10)
			}
			Button() {
				bye.toggle()
				dismiss()
			} label: {
				Text("Continue")
					.font(.headline)
					.frame(height: 40)
					.bold()
//					.frame(maxWidth: .infinity)
			}
			.foregroundStyle(.orange)
			.modifier(glassButton())
			.hapticHeavy(trigger: bye)
		}
		.scrollContentBackground(.hidden)
		.presentationDragIndicator(.visible)
		.onDisappear {
			settingsModel.settings.prevAppVersion = getVersion()+getBuildID()
			settingsModel.saveSettings()
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

struct WhatsNewChunkView: View {
	@State var symbol: String
	@State var title: String
	@State var subtitle: String
	var body: some View {
		HStack {
			Image(systemName: symbol)
				.resizable()
				.scaledToFit()
				.frame(width: 30, height: 30)
				.foregroundStyle(Color.orange)
				.padding(.trailing, 15)
			VStack(alignment: .leading) {
				Text(title)
					.font(.headline)
					.bold()
				Text(subtitle)
					.foregroundStyle(.gray)
					.font(.subheadline)
					.fixedSize(horizontal: false, vertical: true)
			}
		}
	}
}
