//
//  YouAsked.swift
//  NearFuture
//
//  Created by neon443 on 21/05/2025.
//

import SwiftUI
import AudioToolbox

@available(iOS 17.5, *)
struct YouAsked: View {
	let startDate: Date = Date()
	@State var timeElapsed: Int = 0
	let timer = Timer.publish(every: 0.3, on: .current, in: .common).autoconnect()
	
    var body: some View {
		Text("\(timeElapsed)")
			.onReceive(timer) { firedDate in
				timeElapsed = Int(firedDate.timeIntervalSince(startDate))
			}
			.sensoryFeedback(.alignment, trigger: timeElapsed)
			.sensoryFeedback(.decrease, trigger: timeElapsed)
			.sensoryFeedback(.error, trigger: timeElapsed)
			.sensoryFeedback(.impact, trigger: timeElapsed)
			.sensoryFeedback(.increase, trigger: timeElapsed)
			.sensoryFeedback(.levelChange, trigger: timeElapsed)
			.sensoryFeedback(.pathComplete, trigger: timeElapsed)
			.sensoryFeedback(.selection, trigger: timeElapsed)
			.sensoryFeedback(.start, trigger: timeElapsed)
			.sensoryFeedback(.stop, trigger: timeElapsed)
			.sensoryFeedback(.success, trigger: timeElapsed)
			.sensoryFeedback(.warning, trigger: timeElapsed)
			.sensoryFeedback(.warning, trigger: timeElapsed)
    }
}

#Preview {
	if #available(iOS 17.5, *) {
		YouAsked()
	} else {
		Text("update to ios 17 lil bro")
	}
}
