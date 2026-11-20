//
//  Landmark+MapItem.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 09.04.26.
//

import MapKit

/// MapKit-dependent parts of `Landmark`, kept in an extension so that the `Landmark` model itself doesn't have to import MapKit
extension Landmark {
	// todo: is this efficient? move to extension, remove MapKit reference
	func mapItem() -> MKMapItem {
		return MKMapItem(placemark: MKPlacemark(coordinate: location))
	}

	/// The Look Around scene at the landmark's location; nil if Look Around is not available there (or the request failed or was cancelled)
	func lookAroundScene() async -> MKLookAroundScene? {
		try? await MKLookAroundSceneRequest(coordinate: location).scene
	}

	/// Opens Apple Maps with directions to the landmark
	func openDirections() {
		let item = mapItem()
		item.name = localizedName
		item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
	}
}
