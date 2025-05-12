//
//  NearFutureWidgetsBundle.swift
//  NearFutureWidgets
//
//  Created by neon443 on 02/01/2025.
//

import WidgetKit
import SwiftUI

//@main
//struct NearFutureWidgetsBundle: WidgetBundle {
//    var body: some Widget {
//        NearFutureWidgets()
//        NearFutureWidgetsLiveActivity()
//    }
//}

@main
struct NearFutureWidget: Widget {
	let kind: String = "NearFutureWidget"
	
	var body: some WidgetConfiguration {
		StaticConfiguration(kind: kind, provider: EventWidgetProvider()) { entry in
			EventWidgetView(entry: entry)
		}
		.configurationDisplayName("Upcoming Events Widget")
		.description("Displays your upcoming events.")
		.supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
	}
}
