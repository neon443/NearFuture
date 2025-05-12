//
//  HomeView.swift
//  NearFuture
//
//  Created by neon443 on 12/05/2025.
//

import SwiftUI

struct HomeView: View {
	@ObservedObject var viewModel: EventViewModel
	@ObservedObject var settingsModel: SettingsViewModel
	@State private var eventName = ""
	@State private var eventComplete = false
	@State private var eventCompleteDesc = ""
	@State private var eventSymbol = "star"
	@State private var eventColor: Color = randomColor()
	@State private var eventNotes = ""
	@State private var eventDate = Date()
	@State private var eventRecurrence: Event.RecurrenceType = .none
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
						ScrollView {
							ForEach(filteredEvents) { event in
								EventListView(viewModel: viewModel, event: event)
									.transition(.moveAndFade)
									.id(event.complete)
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
						.animation(.default, value: filteredEvents)
						.searchable(text: $searchInput)
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
				}
				.toolbar {
					ToolbarItem(placement: .topBarTrailing) {
						AddEventButton(showingAddEventView: $showingAddEventView)
					}
				}
			}
		}
	}
}


#Preview {
	HomeView(
		viewModel: dummyEventViewModel(),
		settingsModel: dummySettingsViewModel()
	)
}
