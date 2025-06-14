//
//  ArchiveHelp.swift
//  NearFuture
//
//  Created by neon443 on 26/04/2025.
//


import SwiftUI

enum HelpType {
	case Search
	case Archive
	case SymbolsSearch
}

enum Field {
	case Search
}

struct HelpView: View {
	/// initialises a Search HelpView
	/// 
	init(searchInput: Binding<String>, focusedField: Field?) {
		_searchInput = searchInput
		self.helpType = .Search
		_showAddEvent = .constant(false)
	}
	
	/// initialises an Archive HelpView
	/// 
	init(showAddEvent: Binding<Bool>) {
		_showAddEvent = showAddEvent
		self.helpType = .Archive
		_searchInput = .constant("")
		self.focusedField = nil
	}
	
	/// initialises a symbolspciker helpview
	/// - Parameters:
	///   - searchInput: biding string
	///   - searchFocused: a field
	init(symbolsSearchInput: Binding<String>, focusedField: Field?) {
		_searchInput = symbolsSearchInput
		self.helpType = .SymbolsSearch
		_showAddEvent = .constant(false)
	}
	
	@Binding var searchInput: String
	@FocusState var focusedField: Field?
	
	@Binding var showAddEvent: Bool
	
	var helpType: HelpType
	var details: (
		symbol: String,
		title: String,
		body: String,
		buttonAction: () -> (),
		buttonSymbol: String,
		buttonText: String
	) {
		switch helpType {
		case .Search:
			return (
				symbol: "questionmark.app.dashed",
				title: "Looking for something?",
				body: "Tip: The Search bar searches event names and notes.",
				buttonAction: {
					searchInput = ""
					focusedField = nil
				},
				buttonSymbol: "xmark",
				buttonText: "Clear Filters"
			)
		case .Archive:
			return (
				symbol: "eyes",
				title: "Nothing to see here...",
				body: "The Archive contains events that have been marked as complete.",
				buttonAction: {
					showAddEvent.toggle()
				},
				buttonSymbol: "plus",
				buttonText: "Create an event"
			)
		case .SymbolsSearch:
			return (
				symbol: "magnifyingglass",
				title: "You look lost",
				body: "The symbol picker search only works with exact matches, try a different search term.",
				buttonAction: {
					searchInput = ""
				},
				buttonSymbol: "xmark",
				buttonText: "Clear Search bar"
			)
		}
	}
	var body: some View {
		List {
			ZStack {
				Color(.accent)
					.opacity(0.4)
					.padding(.horizontal, -15)
					.blur(radius: 5)
				HStack {
					Image(systemName: details.symbol)
						.resizable()
						.scaledToFit()
						.frame(width: 30, height: 30)
						.padding(.trailing)
					Text(details.title)
						.bold()
						.font(.title2)
				}
			}
			.listRowSeparator(.hidden)
			Text(details.body)
			Button() {
				details.buttonAction()
			} label: {
				HStack {
					Image(systemName: details.buttonSymbol)
						.bold()
					Text(details.buttonText)
				}
				.foregroundStyle(Color.accentColor)
			}
		}
		.scrollContentBackground(.hidden)
	}
}

#Preview {
	HelpView(searchInput: .constant(""), focusedField: nil)
	HelpView(showAddEvent: .constant(false))
}
