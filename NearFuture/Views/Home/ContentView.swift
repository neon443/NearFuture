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
	case home
	case archive
	case stats
	case settings
}
enum FilterCategory {
	case Future
	case Past
	case Complete
	case Incomplete
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
			if settingsModel.settings.showCompletedInHome {
				return viewModel.events
			} else {
				return viewModel.events.filter() {!$0.complete}
			}
		} else {
			return viewModel.events.filter {
				$0.name.localizedCaseInsensitiveContains(searchInput) ||
				$0.notes.localizedCaseInsensitiveContains(searchInput)
			}
		}
	}
	@State private var focusedTab: Tab = .home
	
	@FocusState private var focusedField: Field?

	var body: some View {
		TabView {
			NavigationStack {
				ZStack {
					backgroundGradient
					VStack {
						ZStack {
							TextField(
								"\(Image(systemName: "magnifyingglass")) Search",
								text: $searchInput
							)
							.padding(.trailing, searchInput.isEmpty ? 0 : 30)
							.animation(.spring, value: searchInput)
							.textFieldStyle(RoundedBorderTextFieldStyle())
							.submitLabel(.done)
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
							Button("hiiiiiiiiiiiiiii") {
								withAnimation() {
									settingsModel.settings.showCompletedInHome.toggle()
								}
							}
							Button("sort") {
								withAnimation() {
									viewModel.events.sort() { $0.date < $1.date }
								}
							}
							ScrollView {
								ForEach(filteredEvents) { event in
									EventListView(viewModel: viewModel, event: event)
								}
								.animation(.default, value: filteredEvents)
								.transition(.opacity)
								.id(hey)
								.onReceive(viewModel.objectWillChange) {
									hey = UUID()
								}
								.padding(.horizontal)
								if filteredEvents.isEmpty {
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
				}
			}
			.tabItem {
				Label("Home", systemImage: "house")
			}
			.tag(Tab.home)
			ArchiveView(viewModel: viewModel)
				.tabItem() {
					Label("Archive", systemImage: "tray.full")
				}
				.tag(Tab.archive)
			StatsView(viewModel: viewModel)
				.tabItem {
					Label("Statistics", systemImage: "chart.pie")
				}
				.tag(Tab.stats)
			SettingsView(viewModel: viewModel, settingsModel: settingsModel)
				.tabItem {
					Label("Settings", systemImage: "gear")
				}
				.tag(Tab.settings)
		}
	}
}

#Preview {
	ContentView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
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
