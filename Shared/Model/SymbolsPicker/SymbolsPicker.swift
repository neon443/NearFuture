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
	
	@State var searchInput: String = ""
	
	private func gridLayout(forWidth geoSizeWidth: CGFloat) -> [GridItem] {
		let gridItem = GridItem(.fixed(40), spacing: 20, alignment: .center)
		let columns = Int(geoSizeWidth/60.rounded(.up))
		return Array(repeating: gridItem, count: columns)
	}
	
	var body: some View {
		GeometryReader { geo in
			ScrollView {
				LazyVGrid(columns: gridLayout(forWidth: geo.size.width)) {
					ForEach(symbolsLoader.getSymbols(searchInput), id: \.self) { symbol in
						Button() {
							selection = symbol
						} label: {
							Image(systemName: symbol)
								.resizable()
								.scaledToFit()
								.frame(maxWidth: 40, maxHeight: 40)
								.symbolRenderingMode(.palette)
								.foregroundStyle(.blue, .gray, .black)
						}
						.buttonStyle(.plain)
					}
				}
			}
			.searchable(text: $searchInput)
		}
	}
}

#Preview {
	SymbolsPicker(selection: .constant(""))
}
