//
//  Artefact.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 26.10.24.
//

import MapKit

// properties are named the same as in json structure
struct Artefact: Decodable {

	struct ArtefactsLocation: Decodable {
		var location: CLLocationCoordinate2D {
			return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		}

		let longitude: Double
		let latitude: Double
		let id: UInt64 // ? how long are the ids in json file?
	}

	let artefacts_name: String
	let artefactsLocation: ArtefactsLocation

	func convertToMapItem() -> MKMapItem {
		let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: self.artefactsLocation.location))
		mapItem.name = self.artefacts_name
		return mapItem
	}
}
