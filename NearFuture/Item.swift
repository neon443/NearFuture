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
    @Published var icloudData: [Event] = []
    
    init() {
        loadEvents()
    }
    
    //icloud
    let icloudStore = NSUbiquitousKeyValueStore.default
    
    func loadEvents() {
        //load icloud 1st
        if let icData = icloudStore.data(forKey: "events") {
            let decoder = JSONDecoder()
            if let decodedIcEvents = try? decoder.decode([Event].self, from: icData) {
                self.icloudData = decodedIcEvents
                self.events = decodedIcEvents
            }
        }
        
        if events.isEmpty, let savedData = UserDefaults.standard.data(forKey: "events") {
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
            
//            do {
                icloudStore.set(encoded, forKey: "events")
                icloudStore.synchronize()
//            } catch {
//                print("Error saving to iCloud: \(error)")
//            }
            
            if icloudStore.data(forKey: "events") != nil {
                print(icloudStore.dictionaryRepresentation)
            }
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
    
    //MARK: Danger Zone
    func dangerClearLocalData() {
        UserDefaults.standard.removeObject(forKey: "events")
    }
    func dangerCleariCloudData() {
        let icloud = NSUbiquitousKeyValueStore()
        icloud.removeObject(forKey: "events")
        icloud.synchronize()
    }
    func dangerResetLocalData() {
        let userDFDict = UserDefaults.standard.dictionaryRepresentation()
        for key in userDFDict.keys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    func dangerResetiCloud() {
        let icloud = NSUbiquitousKeyValueStore()
        let icloudDict = NSUbiquitousKeyValueStore().dictionaryRepresentation
        for key in icloudDict.keys {
            icloud.removeObject(forKey: key)
        }
        icloud.synchronize()
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
