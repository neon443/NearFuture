//
//  Settings.swift
//  MacNearFuture
//
//  Created by neon443 on 21/05/2025.
//

import Foundation
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif

struct NFSettings: Codable, Equatable {
	var showCompletedInHome: Bool = false
	var tint: ColorCodable = ColorCodable(.accentColor)
	var showWhatsNew: Bool = true
	var prevAppVersion: String = getVersion()+getBuildID()
}

class SettingsViewModel: ObservableObject {
	@Published var settings: NFSettings = NFSettings()
	
	@Published var notifsGranted: Bool = false
	
	@Published var colorChoices: [AccentIcon] = []
	
	let accentChoices: [String] = [
		"red",
		"orange",
		"yellow",
		"green",
		"blue",
		"bloo",
		"purple",
		"pink"
	]
	
	@Published var device: (sf: String, label: String)
	
	@MainActor
	init(load: Bool = true) {
		self.device = getDevice()
		if load {
			loadSettings()
			Task.detached {
				let requestResult = await requestNotifs()
				await MainActor.run {
					self.notifsGranted = requestResult
				}
			}
		}
	}
	
	func changeTint(to: String) {
#if canImport(UIKit)
		if let uicolor = UIColor(named: "uiColors/\(to)") {
			self.settings.tint = ColorCodable(uiColor: uicolor)
			saveSettings()
		}
#elseif canImport(AppKit)
		if let nscolor = NSColor(named: "uiColors/\(to)") {
			self.settings.tint = ColorCodable(nsColor: nscolor)
		}
#endif
	}
	
	let appGroupSettingsStore = UserDefaults(suiteName: "group.NearFuture") ?? UserDefaults.standard
	let icSettStore = NSUbiquitousKeyValueStore.default
	
	func loadSettings() {
		let decoder = JSONDecoder()
		if let icSettings = icSettStore.data(forKey: "settings") {
			if let decodedSetts = try? decoder.decode(NFSettings.self, from: icSettings) {
				self.settings = decodedSetts
			}
		} else if let savedData = appGroupSettingsStore.data(forKey: "settings") {
			if let decodedSetts = try? decoder.decode(NFSettings.self, from: savedData) {
				self.settings = decodedSetts
			}
		}
		if self.settings.prevAppVersion != getVersion()+getBuildID() {
			self.settings.showWhatsNew = true
		}
	}
	
	func saveSettings() {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(settings) {
			appGroupSettingsStore.set(encoded, forKey: "settings")
			icSettStore.set(encoded, forKey: "settings")
			icSettStore.synchronize()
			loadSettings()
		}
	}
}
