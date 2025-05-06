//
//  ContentView.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 24/12/2024.
//

import SwiftUI
import UserNotifications
import SwiftData

enum Field {
	case Search
}
enum Tab {
	case Home
	case Archive
	case Statistics
	case Settings
	case Gradient
}

struct ContentView: View {
	@StateObject var viewModel: EventViewModel
	@StateObject var settingsModel: SettingsViewModel
	@State private var eventName = ""
	@State private var eventComplete = false
	@State private var eventCompleteDesc = ""
	@State private var eventSymbol = "star"
	@State private var eventColor: Color = randomColor()
	@State private var eventNotes = ""
	@State private var eventDate = Date()
	@State private var eventRecurrence: Event.RecurrenceType = .none
	@State var hey: UUID = UUID()
	@State private var showingAddEventView = false
	@State private var searchInput: String = ""
	var filteredEvents: [Event] {
		if searchInput.isEmpty {
			return viewModel.events.filter() {!$0.complete}
		} else {
			return viewModel.events.filter {
				$0.name.localizedCaseInsensitiveContains(searchInput) ||
				$0.notes.localizedCaseInsensitiveContains(searchInput)
			}
		}
	}
	
	var noEvents: Bool {
		if viewModel.events.count == 0 {
			return true
		} else {
			return false
		}
	}
	
	@FocusState private var focusedField: Field?
	@FocusState private var focusedTab: Tab?

	var body: some View {
		TabView {
			NavigationStack {
				ZStack {
					backgroundGradient
					VStack {
						ZStack {
							SearchBar(searchInput: $searchInput)
								.focused($focusedField, equals: Field.Search)
								.onSubmit {
									focusedField = nil
								}
							MagicClearButton(text: $searchInput)
								.onTapGesture {
									focusedField = nil
								}
						}
						.padding(.horizontal)
						
						if filteredEvents.isEmpty && !searchInput.isEmpty {
							HelpView(searchInput: $searchInput, focusedField: focusedField)
						} else {
							ScrollView {
								ForEach(filteredEvents) { event in
									EventListView(viewModel: viewModel, event: event)
								}
								.onDelete(perform: viewModel.removeEvent)
								.id(hey)
								.onReceive(viewModel.objectWillChange) {
									hey = UUID()
								}
								.padding(.horizontal)
								if /*!searchInput.isEmpty && */filteredEvents.isEmpty {
									HelpView(
										searchInput: $searchInput,
										focusedField: focusedField
									)
								}
								Spacer()
							}
						}
					}
					.navigationTitle("Near Future")
					.apply {
						if #available(iOS 17, *) {
							$0.toolbarTitleDisplayMode(.inlineLarge)
						} else {
							$0.navigationBarTitleDisplayMode(.inline)
						}
					}
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
							eventRecurrence: $eventRecurrence,
							adding: true //adding event
						)
						.presentationDragIndicator(.visible)
						.apply {
							if #available(iOS 16.4, *) {
								$0.presentationBackground(.ultraThinMaterial)
							}
						}
					}
					.toolbar {
						ToolbarItem(placement: .topBarTrailing) {
							AddEventButton(showingAddEventView: $showingAddEventView)
						}
					}
					.onAppear() {
						Task {
							notifsGranted = await requestNotifs()
						}
					}
				}
			}
			.tabItem {
				Label("Home", systemImage: "house")
			}
			.focused($focusedTab, equals: Tab.Home)
			ArchiveView(viewModel: viewModel)
				.tabItem() {
					Label("Archive", systemImage: "tray.full")
				}
				.focused($focusedTab, equals: Tab.Archive)
			StatsView(viewModel: viewModel)
				.tabItem {
					Label("Statistics", systemImage: "chart.pie")
				}
				.focused($focusedTab, equals: Tab.Statistics)
			SettingsView(viewModel: viewModel, settingsModel: settingsModel)
				.tabItem {
					Label("Settings", systemImage: "gear")
				}
				.focused($focusedTab, equals: Tab.Settings)
		}
	}
}

#Preview {
	ContentView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}

struct SearchBar: View {
	@Binding var searchInput: String
	
	var body: some View {
		TextField(
			"\(Image(systemName: "magnifyingglass")) Search",
			text: $searchInput
		)
		.padding(.trailing, searchInput.isEmpty ? 0 : 30)
		.animation(.spring, value: searchInput)
		.textFieldStyle(RoundedBorderTextFieldStyle())
		.submitLabel(.done)
	}
}

struct AddEventButton: View {
	@Binding var showingAddEventView: Bool
	var body: some View {
		Button() {
			showingAddEventView.toggle()
		} label: {
			ZStack {
				Circle()
					.frame(width: 33)
					.foregroundStyle(.one)
				Image(systemName: "plus")
					.resizable()
					.scaledToFit()
					.frame(width: 15)
					.bold()
					.foregroundStyle(.two)
			}
		}
	}
}

extension View {
	var appearance: ColorScheme {
		return UITraitCollection.current.userInterfaceStyle == .dark ? .dark : .light
	}
	var backgroundGradient: some View {
		return LinearGradient(
			gradient: Gradient(colors: [.bgTop, .two]),
			startPoint: .top,
			endPoint: .bottom
		)
		.ignoresSafeArea(.all)
	}
}

extension View {
	func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}
