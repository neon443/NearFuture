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
	@Binding var eventDescription: String
	@Binding var eventDate: Date
	@Binding var eventRecurrence: Event.RecurrenceType
	@Binding var isPresented: Bool
	@State var isSymbolPickerPresented = false
	
	var body: some View {
		Form {
			Section(header: Text("Event Details").font(.headline).foregroundColor(.blue)) {
				// name & symbol
				HStack(spacing: 5) {
					Button() {
						isSymbolPickerPresented.toggle()
					} label: {
						Image(systemName: eventSymbol)
							.resizable()
							.scaledToFit()
							.frame(width: 30, height: 30)
					}
					.buttonStyle(.bordered)
					.sheet(isPresented: $isSymbolPickerPresented) {
						SymbolsPicker(
							selection: $eventSymbol,
							title: "Choose a Symbol",
							searchLabel: "Search...",
							autoDismiss: true)
					}
					Divider()
					ZStack {
						TextField("Event Name", text: $eventName)
							.textFieldStyle(RoundedBorderTextFieldStyle())
							.padding(.trailing, eventName.isEmpty ? 0 : 30)
							.animation(.spring, value: eventName)
						MagicClearButton(text: $eventName)
					}
				}
				
				// dscription
				ZStack {
					TextField("Event Description", text: $eventDescription)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.padding(.trailing, eventDescription.isEmpty ? 0 : 30)
						.animation(.spring, value: eventDescription)
					MagicClearButton(text: $eventDescription)
				}
				
				
				// date picker
				DatePicker("Event Date", selection: $eventDate, in: Date()..., displayedComponents: .date)
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

			// save button
			Button {
				viewModel.addEvent(
					name: eventName,
					symbol: eventSymbol,
					description: eventDescription,
					date: eventDate,
					recurrence: eventRecurrence
				)
				eventName = ""
				eventSymbol = "star"
				eventDescription = ""
				eventDate = Date()
				eventRecurrence = .none
				isPresented = false
			} label: {
				Text("Save Event")
					.font(.headline)
					.cornerRadius(10)
					.shadow(radius: 10)
					.buttonStyle(BorderedProminentButtonStyle())
			}
			.disabled(eventName.isEmpty || eventDescription.isEmpty)
			if eventName.isEmpty && eventDescription.isEmpty {
				Text("Give your event a name and description.")
			} else if eventName.isEmpty {
				Text("Give your event a name.")
			} else if eventDescription.isEmpty {
				Text("Give your event a description.")
			}
		}
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
		}
	}
}

struct AddEvent_Preview: PreviewProvider {
	@State static var symbol = "star"
	@State static var date = Date()
	
	static var previews: some View {
		AddEventView(
			viewModel: EventViewModel(),
			eventName: .constant("Birthday"),
			eventSymbol: $symbol,
			eventDescription: .constant("A very special day"),
			eventDate: $date,
			eventRecurrence: .constant(.monthly),
			isPresented: .constant(true)
		)
	}
}
