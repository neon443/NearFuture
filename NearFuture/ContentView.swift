//
//  ContentView.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 24/12/2024.
//

import SwiftUI
import SwiftData

//struct ContentView: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
//
//    var body: some View {
//        NavigationSplitView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
//                    } label: {
//                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//#if os(macOS)
//            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
//#endif
//            .toolbar {
//#if os(iOS)
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//#endif
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//        } detail: {
//            Text("Select an item")
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//        .modelContainer(for: Item.self, inMemory: true)
//}


struct ContentView: View {
	@StateObject private var viewModel = EventViewModel()
	@State private var eventName = ""
	@State private var eventSymbol = "star"
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
	
	var body: some View {
		NavigationView {
			VStack {
				ZStack {
					TextField(
						"\(Image(systemName: "magnifyingglass")) Search",
						text: $searchInput
					)
					.padding(.trailing, searchInput.isEmpty ? 0 : 30)
					.animation(.spring, value: searchInput)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					MagicClearButton(text: $searchInput)
				}
				.padding(.horizontal)
				List {
					ForEach(filteredEvents) { event in
						EventListView(event: event)
					}
					.onDelete(perform: viewModel.removeEvent)
				}
			}
			.navigationTitle("Near Future")
//			.navigationTitle() {
//				Text("hi")
//			}
			.navigationBarTitleDisplayMode(.inline)
			.sheet(isPresented: $showingAddEventView) {
				AddEventView(
					viewModel: viewModel,
					eventName: $eventName,
					eventSymbol: $eventSymbol,
					eventDescription: $eventDescription,
					eventDate: $eventDate,
					eventRecurrence: $eventRecurrence,
					isPresented: $showingAddEventView
				)
			}
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button(action: {
						showingAddEventView.toggle()
					}) {
						Image(systemName: "plus.circle")
							.resizable()
							.scaledToFit()
					}
				}
			}

		}
	}
}

struct EventListView: View {
	@State var event: Event
	
	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				HStack {
					Image(systemName: event.symbol)
					Text(event.name)
						.font(.headline)
						.padding(.bottom, 2)
				}
				Text(event.description)
					.font(.subheadline)
					.foregroundColor(.gray)
				Text("Recurring: \(event.recurrence.rawValue.capitalized)")
						.font(.subheadline)
						.foregroundColor(.blue)
				Text("In \(daysUntilEvent(event.date))")
					.font(.subheadline)
					.foregroundColor(.gray)
			}
			
			Spacer()
			
			Text(event.date.formatted(date: .long, time: .omitted))
			.font(.subheadline)
			.foregroundColor(.blue)
		}
		.padding(.vertical, 8)
	}
}

#Preview {
	ContentView()
}
