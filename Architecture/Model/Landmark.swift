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
	let title: String
	let URL: URL
	let imageURL: URL?
	let events: [HistoricalEvent]?
	let styleIndexes: [UInt16]
		let synonyms: [Synonym]
	var styles: [Style] = []

	init(location: CLLocationCoordinate2D, id: UInt64, title: String, URL: URL, imageURL: URL?, events: [HistoricalEvent]? = [], styleIndexes: [UInt16], synonyms: [Synonym] = []) {
		self.location = location
		self.title = title
		self.URL = URL
		self.imageURL = imageURL
		self.events = events
		self.id = id
		self.styleIndexes = styleIndexes
		self.synonyms = synonyms
	}

    static func == (lhs: Landmark, rhs: Landmark) -> Bool {
		return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
		hasher.combine(id)
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

