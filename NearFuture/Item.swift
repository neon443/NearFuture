//
//  Item.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 24/12/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Item {
	var timestamp: Date
	
	init(timestamp: Date) {
		self.timestamp = timestamp
	}
}

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

func daysUntilEvent(_ eventDate: Date) -> String {
	let calendar = Calendar.current
	let currentDate = Date()
	let components = calendar.dateComponents([.day], from: currentDate, to: eventDate)
	guard let days = components.day else { return "N/A" }
	guard days >= 0 else {
		return "\(days) days ago"
	}
	guard days != 0 else {
		return "Today"
	}
	return "\(days) days"
}

class EventViewModel: ObservableObject {
	@Published var events: [Event] = []
	
	init() {
		loadEvents()
	}
	
	func loadEvents() {
		if let savedData = UserDefaults.standard.data(forKey: "events") {
			let decoder = JSONDecoder()
			if let decodedEvents = try? decoder.decode([Event].self, from: savedData) {
				self.events = decodedEvents
			}
		}
	}
	
	func saveEvents() {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(events) {
			UserDefaults.standard.set(encoded, forKey: "events")
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
		saveEvents()
	}
	
	func removeEvent(at index: IndexSet) {
		events.remove(atOffsets: index)
		saveEvents()
	}
}

//TODO: make it better lol
func describeOccurrence(date: Date, recurrence: Event.RecurrenceType) -> String {
	switch recurrence {
	case .none:
		return "Occurs once on \(date.formatted(date: .long, time: .omitted))"
	case .daily:
		return "Repeats every day from \(date.formatted(date: .long, time: .omitted))"
	case .weekly:
		return "Repeats every week from \(date.formatted(date: .long, time: .omitted))"
	case .monthly:
		return "Repeats every month from \(date.formatted(date: .long, time: .omitted))"
	case .yearly:
		return "Repeats every month from \(date.formatted(date: .long, time: .omitted))"
	}
}
