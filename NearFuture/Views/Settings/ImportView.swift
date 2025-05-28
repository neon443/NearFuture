//
//  ImportView.swift
//  NearFuture
//
//  Created by neon443 on 02/05/2025.
//

import SwiftUI

struct ImportView: View {
	@ObservedObject var viewModel: EventViewModel
	@Binding var importStr: String
	
	@State private var image: String = "clock.fill"
	@State private var text: String = "Ready..."
	@State private var fgColor: Color = .yellow
	
	@State private var showAlert: Bool = false
	
	@State private var replaceCurrentEvents: Bool = false
	
	var body: some View {
		ZStack(alignment: .center) {
			List {
				Section("Status") {
					Label(text, systemImage: image)
						.contentTransition(.numericText())
						.foregroundStyle(fgColor)
				}
				TextField("", text: $importStr)
				Button() {
					withAnimation {
						showAlert.toggle()
					}
				} label: {
					Label("Import", systemImage: "tray.and.arrow.down.fill")
				}
				.disabled(importStr.isEmpty)
				.onAppear() {
					importStr = ""
					image = "clock.fill"
					text = "Ready..."
					fgColor = .yellow
				}
			}
			.blur(radius: showAlert ? 2 : 0)
			Group {
				Rectangle()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.foregroundStyle(replaceCurrentEvents ? .red.opacity(0.3) : .black.opacity(0.2))
					.animation(.default, value: replaceCurrentEvents)
					.ignoresSafeArea()
				ZStack {
					RoundedRectangle(cornerRadius: 30)
						.foregroundStyle(.one.opacity(0.8))
						.blur(radius: 1)
					VStack(alignment: .center) {
						Text("Are you sure?")
							.font(.largeTitle)
							.bold()
							.foregroundStyle(replaceCurrentEvents ? .red : .two)
							.animation(.default, value: replaceCurrentEvents)
						Text("This will replace your current events!")
							.lineLimit(nil)
							.multilineTextAlignment(.center)
							.opacity(replaceCurrentEvents ? 1 : 0)
							.animation(.default, value: replaceCurrentEvents)
							.foregroundStyle(.two)
						Toggle("Replace Events", isOn: $replaceCurrentEvents)
							.foregroundStyle(.two)
						Spacer()
						Button() {
							withAnimation {
								showAlert.toggle()
							}
							do throws {
								try viewModel.importEvents(importStr, replace: replaceCurrentEvents)
								withAnimation {
									image = "checkmark.circle.fill"
									text = "Complete"
									fgColor = .green
								}
							} catch importError.invalidB64 {
								withAnimation {
									image = "xmark.app.fill"
									text = "Invalid base64 input."
									fgColor = .red
								}
							} catch {
								withAnimation {
									image = "xmark.app.fill"
									text = error.localizedDescription
									fgColor = .red
								}
							}
						} label: {
							Text("yes")
								.font(.title2)
								.bold()
						}
						.buttonStyle(BorderedProminentButtonStyle())
					}
					.padding()
				}
				.frame(maxWidth: 250, maxHeight: 250)
			}
			.opacity(showAlert ? 1 : 0)
		}
	}
}

#Preview {
	ImportView(
		viewModel: dummyEventViewModel(),
		importStr: .constant("kljadfskljafdlkj;==")
	)
}
