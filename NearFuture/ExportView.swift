//
//  ExportView.swift
//  NearFuture
//
//  Created by neon443 on 02/05/2025.
//

import SwiftUI

struct ExportView: View {
	@ObservedObject var viewModel: EventViewModel
	var body: some View {
		List {
			Button() {
				UIPasteboard.general.string = viewModel.exportEvents()
			} label: {
				Label("Copy Events", systemImage: "document.on.clipboard")
			}
			Text(viewModel.exportEvents())
				.textSelection(.enabled)
		}
	}
}

#Preview {
    ExportView(viewModel: dummyEventViewModel())
}
