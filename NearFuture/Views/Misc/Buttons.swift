//
//  MagicClearButton.swift
//  NearFuture
//
//  Created by neon443 on 06/05/2025.
//

import SwiftUI

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

struct AddEventButton: View {
	@Binding var showingAddEventView: Bool
	var body: some View {
		Button() {
			showingAddEventView.toggle()
		} label: {
			ZStack {
				Circle()
					.frame(width: 33)
					.foregroundStyle(.one)
				Image(systemName: "plus")
					.resizable()
					.scaledToFit()
					.frame(width: 15)
					.bold()
					.foregroundStyle(.two)
			}
		}
	}
}

#Preview {
	MagicClearButton(text: .constant("s"))
}

#Preview {
	AddEventButton(showingAddEventView: .constant(false))
}
