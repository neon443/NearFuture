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
	
	var color: Color {
		Color(red: red, green: green, blue: blue)
	}
	var colorBind: Color {
		get {
			return Color(
				red: red,
				green: green,
				blue: blue
			)
		} set {
			let cc = ColorCodable(newValue)
			self.red = cc.red
			self.green = cc.green
			self.blue = cc.blue
		}
	}

	init(_ color: Color) {
		let uiColor = UIColor(color)
		var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1.0
		uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		self.red = Double(r)
		self.green = Double(g)
		self.blue = Double(b)
	}
	init(red: Double, green: Double, blue: Double) {
		self.red = red
		self.green = green
		self.blue = blue
	}
}

func daysUntilEvent(_ eventDate: Date) -> (short: String, long: String) {
	let calendar = Calendar.current
	let currentDate = Date()
	let components = calendar.dateComponents([.day, .hour, .minute], from: currentDate, to: eventDate)
	guard let days = components.day else {
		return ("N/A", "N/A")
	}
	guard let hours = components.hour else {
		return ("N/A", "N/A")
	}
	guard let minutes = components.minute else {
		return ("N/A", "N/A")
	}
	
	enum RetUnit {
		case days
		case hours
		case minutes
	}
	func ret(days: Int = 0, hours: Int = 0, minutes: Int = 0, unit: RetUnit, future: Bool = true) -> (String, String) {
		switch unit {
		case .days:
			return (
				"\(days)d",
				"\(days) day\(plu(-hours))"
			)
		case .hours:
			return (
				"\(hours)h",
				"\(hours) hour\(plu(-hours))"
			)
		case .minutes:
			return (
				"\(minutes)m",
				"\(minutes) min\(plu(-minutes))"
			)
		}
	}
	switch eventDate > Date() {
	case true:
		//future
		if days == 0 {
			if hours == 0 {
				//less than 1h
				return ret(minutes: minutes, unit: .minutes)
			} else {
				//less than 24h
				return ret(hours: hours, unit: .hours)
			}
		} else {
			//grater than 24h
			return ret(days: days, unit: .days)
		}
	case false:
		//past
		if days == 0 {
			if hours == 0 {
				//less than 1h
				return ret(minutes: minutes, unit: .minutes, future: false)
			} else {
				//less than 24h
				return ret(hours: hours, unit: .hours, future: false)
			}
		} else {
			//grater than 24h
			return ret(days: days, unit: .days, future: false)
		}
	}
}

class EventViewModel: ObservableObject {
	@Published var events: [Event] = []
	@Published var icloudData: [Event] = []
	
	public let template: Event = Event(
		name: "",
		complete: false,
		completeDesc: "",
		symbol: "star",
		color: ColorCodable(randomColor()),
		notes: "",
		date: Date(),
		time: false,
		recurrence: .none
	)
	@Published var editableTemplate: Event = Event(
		name: "",
		complete: false,
		completeDesc: "",
		symbol: "star",
		color: ColorCodable(randomColor()),
		notes: "",
		date: Date(),
		time: false,
		recurrence: .none
	)
	@Published var example: Event = Event(
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
	
	@Published var lastSync: Date? = nil
	@Published var icloudEventCount: Int = 0
	@Published var localEventCount: Int = 0
	@Published var syncStatus: String = "Not Synced"
	
	init(load: Bool = true) {
		if load {
			loadEvents()
		}
	}
	
	//appgroup or regular userdefaults
	let appGroupUserDefaults = UserDefaults(suiteName: "group.NearFuture") ?? UserDefaults.standard
	
	//icloud store
	let icloudStore = NSUbiquitousKeyValueStore.default
	
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
			objectWillChange.send()
		}
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
	}
	
	func addEvent(newEvent: Event) {
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
			loadEvents()
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

class dummyEventViewModel: EventViewModel {
	override init(load: Bool = false) {
		super.init(load: false)
		self.events = [self.example, self.template, self.example, self.template]
		self.events[0].complete.toggle()
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

func randomRainbowColor() -> Color {
	return [
		Color.red,
		Color.orange,
		Color.yellow,
		Color.green,
		Color.blue,
		Color.indigo,
		Color.purple
	].randomElement()!
}

func randomColor() -> Color {
	let r = Double.random(in: 0...1)
	let g = Double.random(in: 0...1)
	let b = Double.random(in: 0...1)
	return Color(red: r, green: g, blue: b)
}

func plu(_ inp: Int) -> String {
	var input = inp
	if inp < 0 { input.negate() }
	return "\(input == 1 ? "" : "s")"
}
