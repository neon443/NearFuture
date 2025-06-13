//
//  AccentIcon.swift
//  NearFuture
//
//  Created by neon443 on 13/06/2025.
//

import Foundation
import SwiftUI
#if canImport(AppKit)
import AppKit
#endif


class AccentIcon {
#if canImport(UIKit)
	var icon: UIImage
#elseif canImport(AppKit)
	var icon: NSImage
#endif
	var color: Color
	var name: String
	
	init(_ colorName: String) {
#if canImport(UIKit)
		self.icon = UIImage(named: "AppIcon")!
		self.color = Color(uiColor: UIColor(named: "uiColors/\(colorName)")!)
#elseif canImport(AppKit)
		self.icon = NSImage(imageLiteralResourceName: "AppIcon")
		self.color = Color(nsColor: NSColor(named: "uiColors/\(colorName)")!)
#endif
		
		self.name = colorName
		
		if colorName != "orange" {
			setSelfIcon(to: colorName)
		}
	}
	
	func setSelfIcon(to name: String) {
#if canImport(UIKit)
		self.icon = UIImage(named: name)!
#elseif canImport(AppKit)
		self.icon = NSImage(imageLiteralResourceName: name)
#endif
	}
}
