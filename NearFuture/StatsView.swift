//
//  StatsView.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 05/01/2025.
//

import SwiftUI
import Charts

struct StatsView: View {
	@ObservedObject var viewModel: EventViewModel
	
	var body: some View {
		NavigationStack {
			ZStack {
				backgroundGradient
				List {
					Section(header: Text("Upcoming Events")) {
						let upcomingEvents = viewModel.events.filter { $0.date > Date() }
						Text("\(upcomingEvents.count) upcoming event\(upcomingEvents.count == 1 ? "" : "s")")
							.font(.headline)
							.foregroundStyle(Color.accentColor)
						let pastEvents = viewModel.events.filter { $0.date < Date() }
						Text("\(pastEvents.count) past event\(pastEvents.count == 1 ? "" : "s")")
							.foregroundStyle(.gray)
					}
					
					Section("Events by Month") {
						let eventsByMonth = Dictionary(grouping: viewModel.events, by: { $0.date })
						ForEach(eventsByMonth.keys.sorted(), id: \.self) { month in
							let count = eventsByMonth[month]?.count ?? 0
							Text("\(count) - \(month.formatted(date: .long, time: .omitted))")
						}
					}
					
					Section("Event Count") {
						let eventCount = viewModel.events.count
						Text("\(eventCount) event\(eventCount == 1 ? "" : "s")")
							.font(.headline)
							.foregroundStyle(Color.accentColor)
						
						ForEach(Event.RecurrenceType.allCases, id: \.self) { recurrence in
							let count = viewModel.events.filter { $0.recurrence == recurrence }.count
							let recurrenceStr = recurrence.rawValue.capitalized
							var description: String {
								if recurrenceStr == "None" {
									return "One-Time event\(count == 1 ? "" : "s")"
								} else {
									return "\(recurrenceStr) event\(count == 1 ? "" : "s")"
								}
							}
							Text("\(count) \(description)")
								.font(.subheadline)
								.foregroundStyle(Color.secondary)
						}
					}
				}
				.scrollContentBackground(.hidden)
				.navigationTitle("Statistics")
				.navigationBarTitleDisplayMode(.inline)
			}
		}
	}
}

#Preview {
	StatsView(
		viewModel: dummyEventViewModel()
	)
}
