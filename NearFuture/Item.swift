//
//  Item.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 24/12/2024.
//

import Foundation
import SwiftData
import SwiftUI
import WidgetKit

//@Model
//final class Item {
//    var timestamp: Date
//
//    init(timestamp: Date) {
//        self.timestamp = timestamp
//    }
//}

//MARK: structs
struct Settings: Codable {
	init() {
		self.showCompletedEvents = false
	}
	var showCompletedEvents: Bool
}

struct Event: Identifiable, Codable {
	var id = UUID()
	var name: String
	var complete: Bool
	var completeDesc: String
	var symbol: String
	var color: ColorCodable
	var notes: String
	var date: Date
	var time: Bool
	var recurrence: RecurrenceType
	
	enum RecurrenceType: String, Codable, CaseIterable {
		case none, daily, weekly, monthly, yearly
	}
}

struct ColorCodable: Codable {
	var red: Double
	var green: Double
	var blue: Double
	var alpha: Double
	//for the brainrot kids: alpha is the opacity/transparency of the color,
	//alpha == 0 completely transparent
	//alpha == 1 completely opaque
	
	var color: Color
	
	init(_ color: Color) {
		let uiColor = UIColor(color)
		var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
		uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		self.red = Double(r)
		self.green = Double(g)
		self.blue = Double(b)
		self.alpha = Double(a)
		self.color = Color(red: r, green: g, blue: b, opacity: a)
	}
	init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
		self.red = red
		self.green = green
		self.blue = blue
		self.alpha = alpha
		self.color = Color(red: red, green: green, blue: blue, opacity: alpha)
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let data = try container.decode([Double].self)
		
		self.red = data[0]
		self.green = data[1]
		self.blue = data[2]
		self.alpha = data[3]
		self.color = Color(red: data[0], green: data[1], blue: data[2], opacity: data[3])
	}
	
	func encode(to encoder: any Encoder) throws {
		var container = encoder.unkeyedContainer()
		
		try container.encode(self.red)
		try container.encode(self.green)
		try container.encode(self.blue)
		try container.encode(self.alpha)
	}
}

//MARK: eventviewmodel
class EventViewModel: ObservableObject {
	@Published var example = Event(
		name: "event",
		complete: false,
		completeDesc: "dofajiof",
		symbol: "star",
		color: ColorCodable(.orange),
		notes: "lksdjfakdflkasjlkjl",
		date: Date(),
		time: true,
		recurrence: .daily
	)
	@Published var events: [Event] = []
	@Published var settings: Settings = Settings()
	@Published var icloudData: [Event] = []
	
	@Published var lastSync: Date? = nil
	@Published var icloudEventCount: Int = 0
	@Published var localEventCount: Int = 0
	@Published var syncStatus: String = "Not Synced"
	
	init() {
		loadSettings()
		loadEvents()
	}
	
	//appgroup or regular userdefaults
	let appGroupUserDefaults = UserDefaults(suiteName: "group.com.neon443.NearFuture") ?? UserDefaults.standard
	
	//icloud store
	let icloudStore = NSUbiquitousKeyValueStore.default
	
	func loadSettings() {
		if let settingsData = appGroupUserDefaults.data(forKey: "settings") {
			let decoder = JSONDecoder()
			if let decodedSettings = try? decoder.decode(Settings.self, from: settingsData) {
				self.settings = decodedSettings
			}
		} else {
			//default settings
			self.settings = Settings()
		}
	}
	
	func saveSettings() {
		let encoder = JSONEncoder()
		if let settingsEncoded = try? encoder.encode(settings) {
			print(settingsEncoded)
			UserDefaults.standard.set(settingsEncoded, forKey: "settings")
		}
	}
	
	// load from icloud or local
	func loadEvents() {
		//load icloud 1st
		if let icData = icloudStore.data(forKey: "events") {
			let decoder = JSONDecoder()
			if let decodedIcEvents = try? decoder.decode([Event].self, from: icData) {
				self.icloudData = decodedIcEvents
				self.events = decodedIcEvents
			}
		}
		
		if events.isEmpty, let savedData = appGroupUserDefaults.data(forKey: "events") {
			let decoder = JSONDecoder()
			if let decodedEvents = try? decoder.decode([Event].self, from: savedData) {
				self.events = decodedEvents
			}
		}
		updateSyncStatus()
	}
	
	// save to local and icloud
	func saveEvents() {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(events) {
			appGroupUserDefaults.set(encoded, forKey: "events")
			
			//sync
			icloudStore.set(encoded, forKey: "events")
			icloudStore.synchronize()
			
			updateSyncStatus()
			loadEvents()
			WidgetCenter.shared.reloadAllTimelines()//reload all widgets when saving events
		}
	}
	
	func updateEvent(_ newEvent: Event) {
		if let index = events.firstIndex(where: { $0.id == newEvent.id }) {
			events[index] = newEvent
		}
		saveEvents()
		return
	}
	
	
	private func updateSyncStatus() {
		lastSync = Date()
		icloudEventCount = icloudData.count
		localEventCount = events.count
		
		if icloudEventCount == localEventCount {
			syncStatus = "Successful"
		} else {
			syncStatus = "Pending"
		}
		return
	}
	
	func addEvent(_ newEvent: Event) {
		events.append(newEvent)
		saveEvents() //sync with icloud
	}
	
	func removeEvent(at index: IndexSet) {
		events.remove(atOffsets: index)
		saveEvents() //sync local and icl
	}
	
	func hasUbiquitousKeyValueStore() -> Bool {
		let icloud = NSUbiquitousKeyValueStore.default
		
		let key = "com.neon443.NearFuture.testkey"
		let value = "testValue"
		
		icloud.set(value, forKey: key)
		icloud.synchronize()
		
		if icloud.string(forKey: key) != nil {
			//			print("has UbiquitousKeyValueStore")
			icloud.removeObject(forKey: key)
			icloud.synchronize()
			return true
		} else {
			print("!has UbiquitousKeyValueStore")
			icloud.removeObject(forKey: key)
			icloud.synchronize()
			return false
		}
	}
	
	func sync() {
		NSUbiquitousKeyValueStore.default.synchronize()
		loadEvents()
	}
	
	func replaceLocalWithiCloudData() {
		icloudStore.synchronize()
		self.events = self.icloudData
		saveEvents()
	}
	
	func replaceiCloudWithLocalData() {
		icloudStore.synchronize()
		self.icloudData = self.events
		saveEvents()
	}
	
	func exportEvents() -> String? {
		let encoder = JSONEncoder()
		
		// Custom date encoding strategy to handle date formatting
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
		encoder.dateEncodingStrategy = .formatted(dateFormatter)
		
		do {
			// Encode the events array to JSON data
			let encodedData = try encoder.encode(events)
			
			// Convert the JSON data to a string
			if let jsonString = String(data: encodedData, encoding: .utf8) {
				return jsonString
			} else {
				print("Failed to convert encoded data to string")
				return nil
			}
		} catch {
			print("Failed to encode events: \(error.localizedDescription)")
			return nil
		}
	}
	
	func importEvents(_ imp: String) {
		guard let impData = imp.data(using: .utf8) else {
			print("Failed to convert string to data")
			return
		}
		
		// Create a JSONDecoder
		let decoder = JSONDecoder()
		
		// Add a custom date formatter for decoding the date string
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Adjust this to the date format you're using
		decoder.dateDecodingStrategy = .formatted(dateFormatter)
		
		do {
			// Attempt to decode the events from the provided data
			let decoded = try decoder.decode([Event].self, from: impData)
			print("Successfully decoded events: \(decoded)")
			
			// Save and reload after importing events
			self.events = decoded
			saveEvents()
		} catch {
			// Print error if decoding fails
			print("Failed to decode events: \(error.localizedDescription)")
		}
	}
	
	//MARK: Danger Zone
	func dangerClearLocalData() {
		UserDefaults.standard.removeObject(forKey: "events")
		appGroupUserDefaults.removeObject(forKey: "events")
		events.removeAll()
		updateSyncStatus()
	}
	
	func dangerCleariCloudData() {
		icloudStore.removeObject(forKey: "events")
		icloudStore.synchronize()
		icloudData.removeAll()
		updateSyncStatus()
	}
	
	func dangerResetLocalData() {
		let userDFDict = UserDefaults.standard.dictionaryRepresentation()
		for key in userDFDict.keys {
			UserDefaults.standard.removeObject(forKey: key)
		}
		
		let appGUSDDict = appGroupUserDefaults.dictionaryRepresentation()
		for key in appGUSDDict.keys {
			appGroupUserDefaults.removeObject(forKey: key)
		}
		
		events.removeAll()
		updateSyncStatus()
	}
	
	func dangerResetiCloud() {
		let icloudDict = icloudStore.dictionaryRepresentation
		for key in icloudDict.keys {
			icloudStore.removeObject(forKey: key)
		}
		icloudStore.synchronize()
		icloudData.removeAll()
		updateSyncStatus()
	}
}

func describeOccurrence(date: Date, recurrence: Event.RecurrenceType) -> String {
	let dateString = date.formatted(date: .long, time: .omitted)
	let recurrenceDescription: String
	
	switch recurrence {
	case .none:
		recurrenceDescription = "Occurs once on"
	case .daily:
		recurrenceDescription = "Repeats every day from"
	case .weekly:
		recurrenceDescription = "Repeats every week from"
	case .monthly:
		recurrenceDescription = "Repeats every month from"
	case .yearly:
		recurrenceDescription = "Repeats every year from"
	}
	
	return "\(recurrenceDescription) \(dateString)"
}

func daysUntilEvent(_ eventDate: Date, short: Bool, sepLines: Bool = false) -> String {
	let calendar = Calendar.current
	let currentDate = Date()
	let components = calendar.dateComponents([.day], from: currentDate, to: eventDate)
	guard let days = components.day else { return "N/A" }
	guard days >= 0 else {
		if short {
			return "\(days)d"
		} else {
			return "\(-days)\(sepLines ? "\n" : " ")day\(-days == 1 ? "" : "s") ago"
		}
	}
	guard days != 0 else {
		return "Today"
	}
	if short {
		return "\(days)d"
	} else {
		return "\(days)\(sepLines ? "\n" : " ")day\(days == 1 ? "" : "s")"
	}
}
