//
//  HomeView.swift
//  NearFuture
//
//  Created by neon443 on 12/05/2025.
//

import SwiftUI
import AppIntents

struct HomeView: View {
	@ObservedObject var viewModel: EventViewModel
	@ObservedObject var settingsModel: SettingsViewModel
	
	@State private var showingAddEventView: Bool = false
	@State private var searchInput: String = ""
	@Environment(\.colorScheme) var appearance
	var darkMode: Bool {
		return appearance == .dark
	}
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
					if filteredEvents.isEmpty && !searchInput.isEmpty {
						HelpView(searchInput: $searchInput, focusedField: focusedField)
					} else {
						ScrollView {
//							LazyVStack {
								ForEach(filteredEvents) { event in
									NavigationLink() {
										EditEventView(
											viewModel: viewModel,
											event: Binding(
												get: { event },
												set: { newValue in
													viewModel.editEvent(newValue)
												}
											)
										)
									} label: {
										EventListView(viewModel: viewModel, event: event)
											.id(event)
									}
									.transition(.moveAndFade)
									.contextMenu() {
										Button(role: .destructive) {
											viewModel.removeEvent(event)
										} label: {
											Label("Delete", systemImage: "trash")
												.tint(.red)
										}
									}
								}
								.padding(.horizontal)
//							}
							if filteredEvents.isEmpty {
								HelpView(
									searchInput: $searchInput,
									focusedField: focusedField
								)
							}
							Spacer()
						}
						.animation(.default, value: filteredEvents)
					}
				}
				.searchable(text: $searchInput)
				.navigationTitle("Near Future")
				.modifier(navigationInlineLarge())
				.sheet(isPresented: $showingAddEventView) {
					AddEventView(
						viewModel: viewModel
					)
				}
				.toolbar {
					ToolbarItem(placement: .primaryAction) {
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
