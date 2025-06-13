//
//  ColorCodable.swift
//  NearFuture
//
//  Created by neon443 on 13/06/2025.
//

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

struct ColorCodable: Codable, Equatable {
	init(_ color: Color) {
		var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1
		
#if canImport(UIKit)
		let uiColor = UIColor(color)
		uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
#elseif canImport(AppKit)
		let nscolor = NSColor(color).usingColorSpace(.deviceRGB)
		nscolor!.getRed(&r, green: &g, blue: &b, alpha: &a)
#endif
		
		self = ColorCodable(
			red: r,
			green: g,
			blue: b
		)
	}
#if canImport(UIKit)
	init(uiColor: UIColor) {
		var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1.0
		uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
		self = ColorCodable(
			red: r,
			green: g,
			blue: b
		)
	}
#elseif canImport(AppKit)
	init(nsColor: NSColor) {
		var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1.0
		let nsColor = nsColor.usingColorSpace(.deviceRGB)
		nsColor!.getRed(&r, green: &g, blue: &b, alpha: &a)
		self = ColorCodable(
			red: r,
			green: g,
			blue: b
		)
	}
#endif
	init(red: Double, green: Double, blue: Double) {
		self.red = red
		self.green = green
		self.blue = blue
	}
	
	var red: Double
	var green: Double
	var blue: Double
	
	var color: Color {
		Color(red: red, green: green, blue: blue)
	}
	var colorBind: Color {
		get {
			return Color(
				red: red,
				green: green,
				blue: blue
			)
		} set {
			let cc = ColorCodable(newValue)
			self.red = cc.red
			self.green = cc.green
			self.blue = cc.blue
		}
	}
}
