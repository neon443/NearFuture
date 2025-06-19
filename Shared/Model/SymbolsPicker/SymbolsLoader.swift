//
//  SymbolsLoader.swift
//  NearFuture
//
//  Created by neon443 on 14/06/2025.
//

import Foundation

class SymbolsLoader: ObservableObject {
	private var allSymbols: [String] = []
	
	init() {
		self.allSymbols = getAllSymbols()
	}
	
	func getSymbols(_ searched: String) -> [String] {
		if searched.isEmpty {
			return []
		} else {
			return allSymbols.filter() { $0.localizedCaseInsensitiveContains(searched) }
		}
	}
	
	func getAllSymbols() -> [String] {
		var allSymbols = [String]()
		if let bundle = Bundle(identifier: "com.apple.CoreGlyphs"),
		   let resPath = bundle.path(forResource: "name_availability", ofType: "plist"),
		   let plist = try? NSDictionary(contentsOf: URL(fileURLWithPath: resPath), error: ()),
		   let plistSymbols = plist["symbols"] as? [String: String]
		{
			allSymbols = Array(plistSymbols.keys)
		}
		return allSymbols
	}
}
