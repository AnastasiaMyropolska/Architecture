//
//  PointOfInterest.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 21.03.26.
//

import Foundation
import CoreLocation

/// Presenatation level object representing architectural object shown on the map

struct PointOfInterest: Identifiable, Equatable, Hashable { // use Hashable instead of MapSelectable
	typealias ID = URL
	var id: ID {
		URL! // todo: use either wiki URL or another source URL. or should I use artefact.id?
	}

	let location: CLLocationCoordinate2D
	let title: String
	let URL: URL?
	let imageURL: URL?
	let events: [HistoricalEvent]?


	init(location: CLLocationCoordinate2D, title: String, URL: URL?, imageURL: URL?, events: [HistoricalEvent]? = []) {
		self.location = location
		self.title = title
		self.URL = URL
		self.imageURL = imageURL
		self.events = events
	}

    static func == (lhs: PointOfInterest, rhs: PointOfInterest) -> Bool {
		return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
		hasher.combine(id)
    }

	// -------
	struct HistoricalEvent {

		enum EventType {
			case construction
			case other
		}

		let eventType: EventType
		let eventStart: String
		let eventEnd: String
	}
}

