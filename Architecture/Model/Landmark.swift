//
//  Landmark.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 21.03.26.
//

import Foundation
import CoreLocation

/// Presenatation level object representing architectural object shown on the map

struct Landmark: Identifiable, Equatable, Hashable { // use Hashable instead of MapSelectable

	let id: UInt64
	let location: CLLocationCoordinate2D
	let imageURL: URL?
	let events: [HistoricalEvent]?
	let styleIndexes: [UInt16]
	/// keyed by language code
	private let localizedNames: [String: LocalizedName]
	/// language code of the landmark's own page; used when there is no entry for the user's language
	private let primaryLanguage: String
	var styles: [Style] = []

	/// entry for the user's preferred language, falling back to the landmark's own page language
	private var preferredLocalizedName: LocalizedName? {
		let userLanguage = Locale.preferredLanguages.first.flatMap { Locale(identifier: $0).language.languageCode?.identifier }
		if let userLanguage, let localizedName = localizedNames[userLanguage] {
			return localizedName
		}
		return localizedNames[primaryLanguage]
	}

	var localizedName: String? {
		preferredLocalizedName?.name
	}

	var localizedWebReference: URL? {
		preferredLocalizedName?.webReference
	}

	init(location: CLLocationCoordinate2D, id: UInt64, imageURL: URL?, events: [HistoricalEvent]? = [], styleIndexes: [UInt16], localizedNames: [String: LocalizedName], primaryLanguage: String) {
		self.location = location
		self.imageURL = imageURL
		self.events = events
		self.id = id
		self.styleIndexes = styleIndexes
		self.localizedNames = localizedNames
		self.primaryLanguage = primaryLanguage
	}

    static func == (lhs: Landmark, rhs: Landmark) -> Bool {
		return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
		hasher.combine(id)
    }

	/// Name of a landmark in a single language, with a link to the corresponding wiki page
	struct LocalizedName: Hashable {
		let name: String
		let webReference: URL
	}

	struct HistoricalEvent {

		enum EventType {
			case constructionStarted
			case constructionCompleted
			case other
		}

		let eventType: EventType
		let eventStart: String
		let eventEnd: String
	}
}

