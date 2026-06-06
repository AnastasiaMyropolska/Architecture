//
//  Artefact.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 26.10.24.
//

import Foundation
import CoreLocation

/// Model level object representing architectural object decoded from the server

struct Artefact: Decodable {

	// todo: properties are named the same as in json structure

	// always set according to server developer
	struct ArtefactsLocation: Decodable {
		var location: CLLocationCoordinate2D {
			return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		}

		let longitude: Double
		let latitude: Double
		let id: UInt64 // ? how long are the ids in json file?
	}

	let artefacts_name: String // always set according to server developer
	let artefactsLocation: ArtefactsLocation

	struct ArtefactImage: Decodable {
		let path_to_image: URL
		let id: UInt64
	}

	let artefactsImage: ArtefactImage? // can be missing

	let web_reference_wiki: URL // always set according to server developer

	let id: UInt64 // always set and unique according to server developer

	struct Event: Decodable {
		let event: String
		let event_begin: String
		let event_end: String
		let id:UInt64
	}

	let events: [Event]

	let categories: [UInt16] // always set according to server developer

	//let page_language // always set according to server developer

}


