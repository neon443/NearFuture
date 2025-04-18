//
//  ContentView.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 24/12/2024.
//

import SwiftUI
import SwiftData

enum Field {
	case Search
}

struct ContentView: View {
	@StateObject private var viewModel = EventViewModel()
	@State private var eventName = ""
	@State private var eventComplete = false
	@State private var eventCompleteDesc = ""
	@State private var eventSymbol = "star"
	@State private var eventColor: Color = randomColor()
	@State private var eventNotes = ""
	@State private var eventDate = Date()
	@State private var eventTime = false
	@State private var eventRecurrence: Event.RecurrenceType = .none
	@State private var showingAddEventView = false
	@State private var searchInput: String = ""
	var filteredEvents: [Event] {
		if searchInput.isEmpty {
			return viewModel.events
		} else {
			return viewModel.events.filter {
				$0.name.localizedCaseInsensitiveContains(searchInput) ||
				$0.notes.localizedCaseInsensitiveContains(searchInput)
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
	
	var noEvents: Bool {
		if viewModel.events.count == 0 {
			return true
		} else {
			return false
		}
	}
	
	@FocusState private var focusedField: Field?
	
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
							.submitLabel(.done)
							MagicClearButton(text: $searchInput)
						}
						.padding(.horizontal)
						List {
							ForEach(filteredEvents) { event in
								EventListView(viewModel: viewModel, event: event)
							}
							.onDelete(perform: viewModel.removeEvent)
							if !searchInput.isEmpty {
								SearchHelp(
									searchInput: $searchInput,
									focusedField: _focusedField
								)
							}
						}
					}
					.navigationTitle("Near Future")
					.navigationBarTitleDisplayMode(.inline)
					.sheet(isPresented: $showingAddEventView) {
						AddEventView(
							viewModel: viewModel,
							eventName: $eventName,
							eventComplete: $eventComplete,
							eventCompleteDesc: $eventCompleteDesc,
							eventSymbol: $eventSymbol,
							eventColor: $eventColor,
							eventNotes: $eventNotes,
							eventDate: $eventDate,
							eventTime: $eventTime,
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

struct SearchHelp: View {
	@Binding var searchInput: String
	@FocusState var focusedField: Field?
	var body: some View {
		HStack {
			Image(systemName: "questionmark.square.dashed")
				.resizable()
				.scaledToFit()
				.frame(width: 30, height: 30)
				.padding(.trailing)
			Text("Can't find what you're looking for?")
		}
		Text("Tip: The Search bar searches event names and notes")
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

#Preview {
	ContentView()
}
