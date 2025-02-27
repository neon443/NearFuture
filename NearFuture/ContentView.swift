//
//  ContentView.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 24/12/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	@StateObject private var viewModel = EventViewModel()
	@State private var eventName = ""
	@State private var eventSymbol = "star"
	@State private var eventColor: Color = [
		Color.red,
		Color.orange,
		Color.yellow,
		Color.green,
		Color.blue,
		Color.indigo,
		Color.purple
	].randomElement() ?? Color.red
	@State private var eventDescription = ""
	@State private var eventDate = Date()
	@State private var eventRecurrence: Event.RecurrenceType = .none
	@State private var showingAddEventView = false
	@State private var searchInput: String = ""
	var filteredEvents: [Event] {
		if searchInput.isEmpty {
			return viewModel.events
		} else {
			return viewModel.events.filter {
				$0.name.localizedCaseInsensitiveContains(searchInput) ||
				$0.description.localizedCaseInsensitiveContains(searchInput)
			}
		}
	}

	@Environment(\.colorScheme) var appearance
	private var backgroundGradient: LinearGradient {
		switch appearance {
		case .light:
			return LinearGradient(
				gradient: Gradient(colors: [.gray.opacity(0.2), .white]),
				startPoint: .top,
				endPoint: .bottom
			)
		case .dark:
			return LinearGradient(
				gradient: Gradient(colors: [.gray.opacity(0.2), .black]),
				startPoint: .top,
				endPoint: .bottom)
		@unknown default:
			//red bg gradient for uknown appearance
			return LinearGradient(
				gradient: Gradient(colors: [.red, .black]),
				startPoint: .bottom,
				endPoint: .top
			)
		}
	}
	@State var showSettings: Bool = false
	
	@FocusState private var focusedField: Field?
	private enum Field {
		case Search
	}

	var body: some View {
		TabView {
			NavigationStack {
				ZStack {
					backgroundGradient
						.ignoresSafeArea(.all)
					VStack {
						ZStack {
							TextField(
								"\(Image(systemName: "magnifyingglass")) Search",
								text: $searchInput
							)
							.padding(.trailing, searchInput.isEmpty ? 0 : 30)
							.animation(.spring, value: searchInput)
							.textFieldStyle(RoundedBorderTextFieldStyle())
							.focused($focusedField, equals: Field.Search)
							.onSubmit {
								focusedField = nil
							}
							MagicClearButton(text: $searchInput)
						}
						.padding(.horizontal)
						List {
							ForEach(filteredEvents) { event in
								EventListView(viewModel: viewModel, event: event)
							}
							.onDelete(perform: viewModel.removeEvent)
							if !searchInput.isEmpty {
								HStack {
									Image(systemName: "questionmark.square.dashed")
										.resizable()
										.scaledToFit()
										.frame(width: 30, height: 30)
										.padding(.trailing)
									Text("Can't find what you're looking for?")
								}
								Text("Tip: The Search bar searches event names and descriptions")
								Button() {
									searchInput = ""
									focusedField = nil
								} label: {
									HStack {
										Image(systemName: "xmark")
										Text("Clear Filters")
									}
									.foregroundStyle(Color.accentColor)
								}
							}
						}
					}
					.navigationTitle("Near Future")
					.navigationBarTitleDisplayMode(.inline)
					.sheet(isPresented: $showingAddEventView) {
						AddEventView(
							viewModel: viewModel,
							eventName: $eventName,
							eventSymbol: $eventSymbol,
							eventColor: $eventColor,
							eventDescription: $eventDescription,
							eventDate: $eventDate,
							eventRecurrence: $eventRecurrence,
							adding: true //adding event
						)
					}
					.toolbar {
						ToolbarItem(placement: .topBarTrailing) {
							Button() {
								showingAddEventView.toggle()
							} label: {
								Image(systemName: "plus.circle")
									.resizable()
									.scaledToFit()
							}
						}
					}
				}
			}
			.tabItem {
				Label("Home", systemImage: "house")
			}
			StatsView(viewModel: viewModel)
				.tabItem {
					Label("Statistics", systemImage: "chart.pie")
				}
			SettingsView(viewModel: viewModel)
				.tabItem {
					Label("Settings", systemImage: "gear")
				}
		}
	}
}

struct EventListView: View {
	@StateObject var viewModel: EventViewModel
	@State var event: Event
	
	var body: some View {
		NavigationLink() {
			EditEventView(
				viewModel: viewModel,
				event: $event
			)
		} label: {
			HStack {
				RoundedRectangle(cornerRadius: 5)
					.frame(width: 5)
					.foregroundStyle(event.color.color)
					.padding(.leading, -10)
					.padding(.vertical, 5)
				VStack(alignment: .leading) {
					HStack {
						Image(systemName: event.symbol)
							.resizable()
							.scaledToFit()
							.frame(width: 20, height: 20)
							.foregroundStyle(event.color.color)
						Text("\(event.name)")
							.font(.headline)
					}
					if !event.description.isEmpty {
						Text(event.description)
							.font(.subheadline)
							.foregroundColor(.gray)
					}
					Text(event.date.formatted(date: .long, time: .omitted))
						.font(.subheadline)
						.foregroundColor(event.color.color)
					if event.recurrence != .none {
						Text("Recurring: \(event.recurrence.rawValue.capitalized)")
							.font(.subheadline)
					}
				}
				
				Spacer()
				
				Text("\(daysUntilEvent(event.date, short: false))")
					.font(.subheadline)
					.foregroundColor(event.color.color)
			}
		}
	}
}

#Preview {
	ContentView()
}
