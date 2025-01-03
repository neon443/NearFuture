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
	var symbol: String
	var color: ColorCodable
	var description: String
	var date: Date
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
	//for the brainrotted: alpha is the opacity/transparency of the color,
	//alpha == 0 completely transparent
	//alpha == 1 completely opaque
	
	var color: Color {
		Color(red: red, green: green, blue: blue, opacity: alpha)
	}
	
	init(_ color: Color) {
		let uiColor = UIColor(color)
		var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
		uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
		
		self.red = Double(r)
		self.green = Double(g)
		self.blue = Double(b)
		self.alpha = Double(a)
	}
	init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
		self.red = red
		self.green = green
		self.blue = blue
		self.alpha = alpha
	}
}

func daysUntilEvent(_ eventDate: Date, short: Bool) -> String {
	let calendar = Calendar.current
	let currentDate = Date()
	let components = calendar.dateComponents([.day], from: currentDate, to: eventDate)
	guard let days = components.day else { return "N/A" }
	guard days >= 0 else {
		if short {
			return "\(days)d"
		} else {
			return "\(-days) day\(-days == 1 ? "" : "s") ago"
		}
	}
	guard days != 0 else {
		return "Today"
	}
	if short {
		return "\(days)d"
	} else {
		return "\(days) day\(days == 1 ? "" : "s")"
	}
}

class EventViewModel: ObservableObject {
	@Published var events: [Event] = []
	@Published var icloudData: [Event] = []
	
	@Published var lastSync: Date? = nil
	@Published var icloudEventCount: Int = 0
	@Published var localEventCount: Int = 0
	@Published var syncStatus: String = "Not Synced"
	
	init() {
		loadEvents()
	}
	
	//appgroup or regular userdefaults
	let appGroupUserDefaults = UserDefaults(suiteName: "group.com.neon443.NearFuture") ?? UserDefaults.standard
	
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
	
	func addEvent(
		name: String,
		symbol: String,
		color: ColorCodable,
		description: String,
		date: Date,
		recurrence: Event.RecurrenceType
	) {
		let newEvent = Event(
			name: name,
			symbol: symbol,
			color: color,
			description: description,
			date: date,
			recurrence: recurrence
		)
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
		
		if let retrievedVal = icloud.string(forKey: key) {
			print("has UbiquitousKeyValueStore: retrieved \(retrievedVal)")
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
