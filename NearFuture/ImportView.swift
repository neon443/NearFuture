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
	
	var body: some View {
		List {
			Section("Status") {
				Label(text, systemImage: image)
					.contentTransition(.numericText())
					.foregroundStyle(fgColor)
			}
			TextField("", text: $importStr)
			Button() {
				do throws {
					try viewModel.importEvents(importStr)
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

	}
}

#Preview {
	ImportView(
		viewModel: dummyEventViewModel(),
		importStr: .constant("kljadfskljafdlkj;==")
	)
}
