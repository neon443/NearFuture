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
	
	@Binding var event: Event
	
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
						.foregroundColor(event.color.color)
				) {
					// name & symbol
					HStack(spacing: 5) {
						Button() {
							isSymbolPickerPresented.toggle()
						} label: {
							Image(systemName: event.symbol)
								.resizable()
								.scaledToFit()
								.frame(width: 20, height: 20)
								.foregroundStyle(event.color.color)
						}
						.frame(width: 20)
						.buttonStyle(.borderless)
						.sheet(isPresented: $isSymbolPickerPresented) {
							SymbolsPicker(
								selection: $event.symbol,
								title: "Choose a Symbol",
								searchLabel: "Search...",
								autoDismiss: true)
						}
						
						//TODO: FIXXX
						ColorPicker("", selection: $event.color.color, supportsOpacity: true)
							.fixedSize()
						Divider()
						ZStack {
							TextField("Event Name", text: $event.name)
								.textFieldStyle(RoundedBorderTextFieldStyle())
								.padding(.trailing, event.name.isEmpty ? 0 : 30)
								.animation(.spring, value: event.name)
								.focused($focusedField, equals: Field.Name)
								.submitLabel(.next)
								.onSubmit {
									focusedField = Field.Description
								}
							MagicClearButton(text: $event.name)
						}
					}
					
					// dscription
					ZStack {
						TextField("Event Description", text: $event.description)
							.textFieldStyle(RoundedBorderTextFieldStyle())
							.padding(.trailing, event.description.isEmpty ? 0 : 30)
							.animation(.spring, value: event.description)
							.focused($focusedField, equals: Field.Description)
							.submitLabel(.done)
							.onSubmit {
								focusedField = nil
							}
						MagicClearButton(text: $event.description)
					}
					
					
					// date picker
					HStack {
						DatePicker("", selection: $event.date, displayedComponents: .date)
							.datePickerStyle(WheelDatePickerStyle())
						Button() {
							event.date = Date()
						} label: {
							Image(systemName: "arrow.uturn.backward")
						}
						.buttonStyle(BorderlessButtonStyle())
					}
					
					Toggle("Schedule a Time", isOn: $event.time)
					if event.time {
						DatePicker(
							"",
							selection: $event.date,
							displayedComponents: .hourAndMinute
						)
					}
					
					// re-ocurrence Picker
					Picker("Recurrence", selection: $event.recurrence) {
						ForEach(Event.RecurrenceType.allCases, id: \.self) { recurrence in
							Text(recurrence.rawValue.capitalized)
						}
					}
					.pickerStyle(SegmentedPickerStyle())
					Text(
						describeOccurrence(
							date: event.date,
							recurrence: event.recurrence
						)
					)
				}
				
				// save button only show iff adding new event
				if adding {
					Button {
						viewModel.addEvent(event)
						resetAddEventView()
					} label: {
						Text("Save Event")
							.font(.headline)
							.cornerRadius(10)
							.buttonStyle(BorderedProminentButtonStyle())
					}
					.disabled(event.name.isEmpty)
					if event.name.isEmpty {
						HStack {
							Image(systemName: "exclamationmark")
								.foregroundStyle(.red)
							Text("Give your event a name.")
						}
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
		event.name = ""
		event.symbol = "star"
		event.color = [
			ColorCodable(.red),
			ColorCodable(.orange),
			ColorCodable(.yellow),
			ColorCodable(.green),
			ColorCodable(.blue),
			ColorCodable(.indigo),
			ColorCodable(.purple)
		].randomElement()!
		event.description = ""
		event.date = Date()
		event.recurrence = .none
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

#Preview {
	AddEventView(
		viewModel: EventViewModel(),
		event: .constant(
			Event(
				name: "event",
				complete: false,
				completeDesc: "dofajiof",
				symbol: "star",
				color: ColorCodable(.orange),
				description: "lksdjfakdflkasjlkjl",
				date: Date(),
				time: true,
				recurrence: .daily
			)
		),
		adding: false
	)
}
