//
//  AddEventView.swift
//  NearFuture
//
//  Created by neon443 on 25/12/2024.
//

import SwiftUI

struct AddEventView: View {
	@ObservedObject var viewModel: EventViewModel
	
	@State var event: Event = dummyEventViewModel().template
	
	@State var adding: Bool = true
	@State var showNeedsNameAlert: Bool = false
	@State var isSymbolPickerPresented: Bool = false
	
	@State private var bye: Bool = false
	
	@FocusState private var focusedField: Field?
	private enum Field {
		case Name, Notes
	}
	
	@Environment(\.dismiss) var dismiss
	
	var isMac: Bool {
		if #available(iOS 1, *) {
			return false
		} else {
			return true
		}
	}
	
	var body: some View {
		ZStack {
			if !adding {
				backgroundGradient
			}
			NavigationStack {
				List {
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
									selection: $event.symbol
								)
								.presentationDetents([.medium])
								.modifier(presentationSizeForm())
							}
							TextField("Event Name", text: $event.name)
								.textFieldStyle(.roundedBorder)
						}
						
						// dscription
						ZStack {
							TextField("Event Notes", text: $event.notes)
								.textFieldStyle(RoundedBorderTextFieldStyle())
								.padding(.trailing, event.notes.isEmpty ? 0 : 30)
								.animation(.spring, value: event.notes)
								.focused($focusedField, equals: Field.Notes)
								.submitLabel(.done)
								.onSubmit {
									focusedField = nil
								}
						}
						
						ColorPicker("Event Color", selection: $event.color.colorBind)
						
						// date picker
						HStack {
							Spacer()
							DatePicker("", selection: $event.date, displayedComponents: .date)
							#if os(iOS)
								.datePickerStyle(.wheel)
							#else
								.datePickerStyle(.graphical)
							#endif
							Spacer()
							Button() {
								event.date = Date()
							} label: {
								Image(systemName: "arrow.uturn.left")
									.resizable()
									.scaledToFit()
							}
							.buttonStyle(BorderlessButtonStyle())
							.frame(width: 20)
						}
						
						DatePicker(
							"",
							selection: $event.date,
							displayedComponents: .hourAndMinute
						)
						#if os(macOS)
						.datePickerStyle(.stepperField)
						#endif
						
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
				}
				.navigationTitle("\(adding ? "Add Event" : "")")
				.modifier(navigationInlineLarge())
				.toolbar {
					ToolbarItem(placement: .cancellationAction) {
						if adding {
							Button() {
								resetAddEventView()
								dismiss()
							} label: {
								Image(systemName: "xmark")
									.resizable()
									.scaledToFit()
									.tint(.one)
							}
						}
					}
					ToolbarItem() {
						if adding {
							Button {
								viewModel.addEvent(
									newEvent: event
								)
								bye.toggle()
								resetAddEventView()
							} label: {
								Label("Save", systemImage: "checkmark")
							}
							.tint(.accent)
							.modifier(hapticSuccess(trigger: bye))
							.disabled(event.name.isEmpty)
							.onTapGesture {
								if event.name.isEmpty {
									showNeedsNameAlert.toggle()
								}
							}
							.alert("Missing Name", isPresented: $showNeedsNameAlert) {
								Button("OK", role: .cancel) {
									showNeedsNameAlert.toggle()
									focusedField = .Name
								}
							} message: {
								Text("Give your Event a name before saving.")
							}
						}
					}
					ToolbarItem(placement: .confirmationAction) {
						if !adding {
							Button() {
								viewModel.editEvent(event)
								dismiss()
							} label: {
								Label("Done", systemImage: "checkmark")
							}
							.disabled(event.name == "")
						}
					}
				}
				.navigationTitle("Editing \(event.name) - Ne")
			}
			.scrollContentBackground(isMac ? .automatic : .hidden)
			.presentationDragIndicator(.visible)
		}
	}
	func resetAddEventView() {
		//reset addeventView
		event = viewModel.template
		dismiss()
	}
	
}

#Preview {
	let vm = dummyEventViewModel()
	Color.orange
		.ignoresSafeArea(.all)
		.sheet(isPresented: .constant(true)) {
			AddEventView(
				viewModel: vm,
				adding: true
			)
		}
}
