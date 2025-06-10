//
//  AddEventView.swift
//  NearFuture
//
//  Created by neon443 on 25/12/2024.
//

import SwiftUI
import SFSymbolsPicker

struct AddEventView: View {
	@ObservedObject var viewModel: EventViewModel
	
	@Binding var eventName: String
	@Binding var eventComplete: Bool
	@Binding var eventCompleteDesc: String
	@Binding var eventSymbol: String
	@Binding var eventColor: Color
	@Binding var eventNotes: String
	@Binding var eventDate: Date
	@Binding var eventRecurrence: Event.RecurrenceType
	
	@State var adding: Bool
	@State var showNeedsNameAlert: Bool = false
	@State var isSymbolPickerPresented: Bool = false
	
	@State private var bye: Bool = false
	
	@FocusState private var focusedField: Field?
	private enum Field {
		case Name, Notes
	}
	
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		ZStack {
			if !adding {
				backgroundGradient
			}
			NavigationStack {
				Form {
					LazyVStack {
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
									.presentationDetents([.medium])
									.apply {
										if #available(iOS 16.4, *) {
											$0.presentationBackground(.ultraThinMaterial)
										}
									}
								}
								ColorPicker("", selection: $eventColor, supportsOpacity: false)
									.fixedSize()
								ZStack {
									TextField("Event Name", text: $eventName)
										.textFieldStyle(RoundedBorderTextFieldStyle())
										.padding(.trailing, eventName.isEmpty ? 0 : 30)
										.animation(.spring, value: eventName)
										.focused($focusedField, equals: Field.Name)
										.submitLabel(.next)
										.onSubmit {
											focusedField = .Notes
										}
									//								MagicClearButton(text: $eventName)
								}
							}
							
							// dscription
							ZStack {
								TextField("Event Notes", text: $eventNotes)
									.textFieldStyle(RoundedBorderTextFieldStyle())
									.padding(.trailing, eventNotes.isEmpty ? 0 : 30)
									.animation(.spring, value: eventNotes)
									.focused($focusedField, equals: Field.Notes)
									.submitLabel(.done)
									.onSubmit {
										focusedField = nil
									}
								//							MagicClearButton(text: $eventNotes)
							}
							
							
							// date picker
							HStack {
								Spacer()
								DatePicker("", selection: $eventDate, displayedComponents: .date)
								//								.datePickerStyle(datepickersty)
								Spacer()
								Button() {
									eventDate = Date()
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
								selection: $eventDate,
								displayedComponents: .hourAndMinute
							)
							
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
					}
				}
				.scrollContentBackground(.hidden)
				.navigationTitle("\(adding ? "Add Event" : "")")
				//				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
#if canImport(UIKit)
					ToolbarItem(placement: .topBarLeading) {
						if adding {
							Button() {
								resetAddEventView()
								dismiss()
							} label: {
								Image(systemName: "xmark")
									.resizable()
									.scaledToFit()
									.frame(width: 30)
							}
						}
					}
#else
					ToolbarItem() {
						if adding {
							Button() {
								resetAddEventView()
								dismiss()
							} label: {
								Image(systemName: "xmark")
									.resizable()
									.scaledToFit()
									.frame(width: 30)
							}
						}
					}
#endif
					ToolbarItem/*(placement: .topBarTrailing)*/ {
						if adding {
							Button {
								viewModel.addEvent(
									newEvent: Event(
										name: eventName,
										complete: eventComplete,
										completeDesc: eventCompleteDesc,
										symbol: eventSymbol,
										color: ColorCodable(eventColor),
										notes: eventNotes,
										date: eventDate,
										recurrence: eventRecurrence
									)
								)
								bye.toggle()
								resetAddEventView()
							} label: {
								Text("Save")
									.font(.headline)
									.cornerRadius(10)
									.buttonStyle(BorderedProminentButtonStyle())
							}
							.tint(.accent)
							.apply {
								if #available(iOS 17, *) {
									$0.sensoryFeedback(.success, trigger: bye)
								}
							}
							.disabled(eventName.isEmpty)
							.onTapGesture {
								if eventName.isEmpty {
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
							if eventName.isEmpty {
								HStack {
									Image(systemName: "exclamationmark")
										.foregroundStyle(.red)
									Text("Give your event a name.")
								}
							}
						}
					}
				}
			}
			.presentationDragIndicator(.visible)
			.scrollContentBackground(.hidden)
		}
		.apply {
			if #available(iOS 16.4, *) {
				$0.presentationBackground(.ultraThinMaterial)
			}
		}
	}
	func resetAddEventView() {
		//reset addeventView
		eventName = viewModel.template.name
		eventComplete = viewModel.template.complete
		eventCompleteDesc = viewModel.template.completeDesc
		eventSymbol = viewModel.template.symbol
		eventColor = randomColor()
		eventNotes = viewModel.template.notes
		eventDate = viewModel.template.date
		eventRecurrence = viewModel.template.recurrence
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
				eventName: .constant(vm.template.notes),
				eventComplete: .constant(vm.template.complete),
				eventCompleteDesc: .constant(vm.template.completeDesc),
				eventSymbol: .constant(vm.template.symbol),
				eventColor: .constant(vm.template.color.color),
				eventNotes: .constant(vm.template.notes),
				eventDate: .constant(vm.template.date),
				eventRecurrence: .constant(vm.template.recurrence),
				adding: true
			)
		}
}
