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
	
	var body: some View {
		NavigationView {
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
						MagicClearButton(text: $searchInput)
					}
					.padding(.horizontal)
					List {
						ForEach(filteredEvents) { event in
							var eventBackgroundGradient: LinearGradient {
								return LinearGradient(
									colors: [
										event.color.color,
										Color.black
									],
									startPoint: .leading,
									endPoint: .trailing
								)
							}
							EventListView(event: event)
						}
						.onDelete(perform: viewModel.removeEvent)
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
						isPresented: $showingAddEventView
					)
				}
				.sheet(
					isPresented: $showSettings) {
						SettingsView(
							viewModel: viewModel,
							showSettings: $showSettings
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
					ToolbarItem(placement: .topBarLeading) {
						Button() {
							showSettings.toggle()
						} label: {
							Image(systemName: "gear")
						}
					}
				}
			}

		}
	}
}

struct EventListView: View {
	@State var event: Event
	
	var body: some View {
//		var testColor = Color.red
//		var codableColor = ColorCodable(testColor)
//		Text("\(codableColor.red), \(codableColor.green), \(codableColor.blue), \(codableColor.alpha)")
		ZStack {
			HStack {
				RoundedRectangle(cornerRadius: 5)
					.frame(width: 5)
					.foregroundStyle(event.color.color)
					.padding(.leading, -5)
				VStack(alignment: .leading) {
					HStack {
						Text("\(Image(systemName: event.symbol)) \(event.name)")
							.font(.headline)
					}
					Text(event.description)
						.font(.subheadline)
						.foregroundColor(.gray)
					if event.recurrence != .none {
						Text("Recurring: \(event.recurrence.rawValue.capitalized)")
							.font(.subheadline)
							.foregroundColor(.blue)
					}
					Text(event.date.formatted(date: .long, time: .omitted))
						.font(.subheadline)
						.foregroundColor(.blue)
				}
				
				Spacer()
				
				Text("\(daysUntilEvent(event.date))")
					.font(.subheadline)
					.foregroundColor(.gray)
			}
			.padding(.vertical, 8)
		}
	}
}
#Preview {
	ContentView()
}
