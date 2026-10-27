//
//  Style.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 06.06.26.
//

import Foundation

struct Style {
	let index: UInt16
	/// keyed by language code
	private let localizedStylesNames: [String: LocalizedStyleName]
	/// language code of the style's own page; used when there is no entry for the user's language
	private let primaryLanguage: String

	/// entry for the user's preferred language, falling back to the style's own page language
	private var preferredLocalizedStyleName: LocalizedStyleName? {
		let userLanguage = Locale.preferredLanguages.first.flatMap { Locale(identifier: $0).language.languageCode?.identifier }
		if let userLanguage, let localizedStyleName = localizedStylesNames[userLanguage] {
			return localizedStyleName
		}
		return localizedStylesNames[primaryLanguage]
	}

	var localizedName: String? {
		preferredLocalizedStyleName?.name
	}

	var localizedWebReference: URL? {
		preferredLocalizedStyleName?.webReference
	}

	init(index: UInt16, localizedStylesNames: [String: LocalizedStyleName], primaryLanguage: String) {
		self.index = index
		self.localizedStylesNames = localizedStylesNames
		self.primaryLanguage = primaryLanguage
	}

	/// Name of a style in a single language, with a link to the corresponding wiki page
	struct LocalizedStyleName: Hashable {
		let name: String
		let webReference: URL
	}
}
