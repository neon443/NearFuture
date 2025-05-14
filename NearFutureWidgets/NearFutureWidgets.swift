//
//  NearFutureWidgets.swift
//  NearFutureWidgets
//
//  Created by neon443 on 02/01/2025.
//

import WidgetKit
import SwiftUI

// Timeline Entry for Widget
struct EventWidgetEntry: TimelineEntry {
	let date: Date
	let events: [Event]
}

// Timeline Provider to handle widget data
struct EventWidgetProvider: TimelineProvider {
	func placeholder(in context: Context) -> EventWidgetEntry {
		EventWidgetEntry(date: Date(), events: [])
	}
	
	func getSnapshot(in context: Context, completion: @escaping (EventWidgetEntry) -> ()) {
		let entry = EventWidgetEntry(date: Date(), events: getEvents())
		completion(entry)
	}
	
	func getTimeline(in context: Context, completion: @escaping (Timeline<EventWidgetEntry>) -> ()) {
		let events = getEvents()
		let currentDate = Date()
		
		// Timeline entry for the current date
		let entry = EventWidgetEntry(date: currentDate, events: events)
		
		// Set timeline to refresh every 15 minutes
		let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
		let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
		
		completion(timeline)
	}
	
	private func getEvents() -> [Event] {
		let viewModel = EventViewModel()
		viewModel.loadEvents()
		return viewModel.events
	}
}

// Event Widget View
struct EventWidgetView: View {
	var entry: EventWidgetEntry
	@Environment(\.widgetFamily) var widgetFamily
	var showedEventsNum: Int {
		switch widgetFamily {
		case .systemSmall:
			return 3
		case .systemMedium:
			return 3
		case .systemLarge:
			return 6
		default:
			return 3
		}
	}
	
	let bgGradient = LinearGradient(
		gradient: Gradient(
			colors: [
				.black,
				.gray.opacity(0.2)
			]
		),
		startPoint: .bottom,
		endPoint: .top
	)
	
	var body: some View {
		let isLarge = widgetFamily == .systemLarge
		let events = entry.events.filter(){!$0.complete}
		ZStack {
			bgGradient
				.padding(.top, 4)
				.padding(.horizontal, -50)
				.padding(.bottom, -100)
			VStack {
				Text("In the Near Future...")
					.foregroundStyle(.white)
					.font(.caption)
					.bold()
					.padding(.top, -12)
				
				ForEach(events.prefix(showedEventsNum), id: \.id) { event in
					HStack {
						RoundedRectangle(cornerRadius: 5)
							.frame(width: 5)
							.frame(maxHeight: isLarge ? 50 : 30)
							.foregroundStyle(event.color.color)
							.padding(.leading, -18)
							.padding(.vertical, 2)
						VStack(alignment: .leading) {
							HStack {
								Image(systemName: event.symbol)
									.resizable()
									.scaledToFit()
									.frame(width: 15, height: 15)
									.foregroundStyle(event.color.color)
								Text("\(event.name.isEmpty ? " " : event.name)")
									.foregroundStyle(.white)
									.font(.footnote)
									.padding(.leading, -5)
							}
							
							if isLarge {
								Text(event.date.formatted(date: .long, time: .omitted))
									.font(.caption2)
									.foregroundColor(event.color.color)
									.padding(.top, -5)
							}
							if event.recurrence != .none {
								Text("\(event.recurrence.rawValue.capitalized)")
									.foregroundStyle(.white)
									.font(.caption2)
									.padding(.top, -5)
							}
						}
						.padding(.leading, -15)
						
						Spacer()
						
						//short days till if not large widget
						if !isLarge {
							Text(daysUntilEvent(event.date).short)
								.font(.caption)
								.multilineTextAlignment(.trailing)
								.foregroundColor(event.date < Date() ? .red : .primary)
								.padding(.trailing, -12)
						} else {
							Text(daysUntilEvent(event.date).long)
								.font(.caption)
								.multilineTextAlignment(.trailing)
								.foregroundColor(event.date < Date() ? .red : .primary)
								.padding(.trailing, -12)
						}
					}
				}
				Spacer()
				if showedEventsNum < events.count {
					let xMoreEvents = events.count - showedEventsNum
					Text("+\(xMoreEvents) more event\(xMoreEvents == 1 ? "" : "s")")
						.font(.caption2)
						.padding(.top, -5)
						.padding(.bottom, -15)
				}
			}
			.containerBackground(Color.widgetBackground, for: .widget)
		}
	}
}

struct Widget_Previews: PreviewProvider {
	static var events = dummyEventViewModel().events
	static var previews: some View {
		EventWidgetView(
			entry: EventWidgetEntry(
				date: Date(),
				events: events
			)
		)
		.previewContext(WidgetPreviewContext(family: .systemLarge))
		.previewDisplayName("Large")
		EventWidgetView(
			entry: EventWidgetEntry(
				date: Date(),
				events: events
			)
		)
		.previewContext(WidgetPreviewContext(family: .systemMedium))
		.previewDisplayName("Medium")
		EventWidgetView(
			entry: EventWidgetEntry(
				date: Date(),
				events: events
			)
		)
		.previewContext(WidgetPreviewContext(family: .systemSmall))
		.previewDisplayName("Small")
	}
}
