//
//  SymbolsPicker.swift
//  NearFuture
//
//  Created by neon443 on 14/06/2025.
//

import SwiftUI

struct SymbolsPicker: View {
	@StateObject private var symbolsLoader = SymbolsLoader()
	@Binding var selection: String
	
	@FocusState var searchfocuesd: Bool
	
	@State var searchInput: String = ""
	@State var browsing: Bool = false
	@Environment(\.dismiss) var dismiss
	
	var symbols: [String] {
		return symbolsLoader.getSymbols(searchInput)
	}
	
	private func gridLayout(forWidth geoSizeWidth: CGFloat) -> [GridItem] {
		let gridItem = GridItem(.fixed(80), spacing: 20, alignment: .center)
		let columns = Int(geoSizeWidth/100.rounded(.up))
		return Array(repeating: gridItem, count: columns)
	}
	
	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				ScrollView {
					if symbols.isEmpty {
						HStack {
							Image(systemName: "magnifyingglass")
								.resizable().scaledToFit()
								.frame(width: 30)
							Text("You look lost")
								.font(.title)
								.bold()
						}
						.padding()
						Text("The symbol picker search only works with exact matches, try a different search term.")
					}
					LazyVGrid(columns: gridLayout(forWidth: geo.size.width)) {
						ForEach(symbols, id: \.self) { symbol in
							Button() {
								selection = symbol
								searchInput = ""
								dismiss()
							} label: {
								VStack {
									Image(systemName: symbol)
										.resizable()
										.scaledToFit()
										.symbolRenderingMode(.palette)
										.foregroundStyle(.blue, .gray, .black)
									Text(symbol)
										.truncationMode(.middle)
										.font(.footnote)
								}
							}
							.frame(maxWidth: 80, maxHeight: 80)
							.buttonStyle(.plain)
						}
					}
				}
			}
			.searchable(text: $searchInput)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					if !browsing {
						Button() {
							searchInput = ""
							dismiss()
						} label: {
							Label("Cancel", systemImage: "xmark")
						}
					}
				}
			}
		}
	}
}

#Preview {
	SymbolsPicker(selection: .constant(""))
}
