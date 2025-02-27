//
//  AddEventView.swift
//  NearFuture
//
//  Created by Nihaal Sharma on 25/12/2024.
//

import SwiftUI
import SFSymbolsPicker

struct AddEventView: View {
	@ObservedObject var viewModel: EventViewModel
	
	@Binding var eventName: String
	@Binding var eventSymbol: String
	@Binding var eventColor: Color
	@Binding var eventDescription: String
	@Binding var eventDate: Date
	@Binding var eventRecurrence: Event.RecurrenceType
	
	@State var adding : Bool
	@State var isSymbolPickerPresented = false
	
	@FocusState private var focusedField: Field?
	private enum Field {
		case Name, Description
	}

	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		NavigationStack {
			Form {
				Section(
					header:
						Text("Event Details")
						.font(.headline)
						.foregroundColor(.accentColor)
				) {
					// name & symbol
					HStack(spacing: 5) {
						Button() {
							isSymbolPickerPresented.toggle()
						} label: {
							Image(systemName: eventSymbol)
								.resizable()
								.scaledToFit()
								.frame(width: 20, height: 20)
								.foregroundStyle(eventColor)
						}
						.frame(width: 20)
						.buttonStyle(.borderless)
						.sheet(isPresented: $isSymbolPickerPresented) {
							SymbolsPicker(
								selection: $eventSymbol,
								title: "Choose a Symbol",
								searchLabel: "Search...",
								autoDismiss: true)
						}
						ColorPicker("", selection: $eventColor, supportsOpacity: true)
							.fixedSize()
						Divider()
						ZStack {
							TextField("Event Name", text: $eventName)
								.textFieldStyle(RoundedBorderTextFieldStyle())
								.padding(.trailing, eventName.isEmpty ? 0 : 30)
								.animation(.spring, value: eventName)
								.focused($focusedField, equals: Field.Name)
								.onSubmit {
									focusedField = .Description
								}
							MagicClearButton(text: $eventName)
						}
					}
					
					// dscription
					ZStack {
						TextField("Event Description", text: $eventDescription)
							.textFieldStyle(RoundedBorderTextFieldStyle())
							.padding(.trailing, eventDescription.isEmpty ? 0 : 30)
							.animation(.spring, value: eventDescription)
							.focused($focusedField, equals: Field.Description)
							.onSubmit {
								focusedField = nil
							}
						MagicClearButton(text: $eventDescription)
					}
					
					
					// date picker
					DatePicker("", selection: $eventDate, displayedComponents: .date)
						.datePickerStyle(WheelDatePickerStyle())
					
					// re-ocurrence Picker
					Picker("Recurrence", selection: $eventRecurrence) {
						ForEach(Event.RecurrenceType.allCases, id: \.self) { recurrence in
							Text(recurrence.rawValue.capitalized)
						}
					}
					.pickerStyle(SegmentedPickerStyle())
					Text(
						describeOccurrence(
							date: eventDate,
							recurrence: eventRecurrence
						)
					)
				}
				
				// save button only show iff adding new event
				if adding {
					Button {
						viewModel.addEvent(
							name: eventName,
							symbol: eventSymbol,
							color: ColorCodable(eventColor),
							description: eventDescription,
							date: eventDate,
							recurrence: eventRecurrence
						)
						resetAddEventView()
					} label: {
						Text("Save Event")
							.font(.headline)
							.cornerRadius(10)
							.buttonStyle(BorderedProminentButtonStyle())
						if eventName.isEmpty {
							Text("Give your event a name.")
						}
					}
					.disabled(eventName.isEmpty)
					if eventName.isEmpty {
						Text("Give your event a name.")
						
					}
				}
			}
			.navigationTitle("\(adding ? "Add Event" : "")")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					if adding {
						Button() {
							dismiss()
						} label: {
							Image(systemName: "xmark.circle.fill")
								.symbolRenderingMode(.hierarchical)
						}
					}
				}
			}
		}
	}
	func resetAddEventView() {
		//reset addeventView
		eventName = ""
		eventSymbol = "star"
		eventColor = [
			Color.red,
			Color.orange,
			Color.yellow,
			Color.green,
			Color.blue,
			Color.indigo,
			Color.purple
		].randomElement() ?? Color.red
		eventDescription = ""
		eventDate = Date()
		eventRecurrence = .none
		dismiss()
	}
}
struct MagicClearButton: View {
	@Binding var text: String
	var body: some View {
		HStack {
			Spacer()
			Button {
				text = ""
			} label: {
				Image(systemName: "xmark.circle.fill")
					.resizable()
					.scaledToFit()
					.frame(width: text.isEmpty ? 0 : 25)
					.symbolRenderingMode(.hierarchical)
					.padding(.trailing, -5)
					.animation(.spring, value: text.isEmpty)
			}
			.buttonStyle(.borderless)
		}
	}
}

struct AddEvent_Preview: PreviewProvider {
	@State static var symbol = "star"
	@State static var date = Date()
	@State static var color = Color(.red)
	
	static var previews: some View {
		AddEventView(
			viewModel: EventViewModel(),
			eventName: .constant("Birthday"),
			eventSymbol: $symbol,
			eventColor: $color,
			eventDescription: .constant("A very special day"),
			eventDate: $date,
			eventRecurrence: .constant(.monthly),
			adding: true
		)
	}
}

