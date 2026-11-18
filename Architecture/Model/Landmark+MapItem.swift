//
//  Landmark+MapItem.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 09.04.26.
//

import MapKit

extension Landmark {
	// todo: is this efficient? move to extension, remove MapKit reference
	func mapItem() -> MKMapItem {
		return MKMapItem(placemark: MKPlacemark(coordinate: location))
	}

	/// Opens Apple Maps with directions to the landmark
	func openDirections() {
		let item = mapItem()
		item.name = localizedName
		item.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault])
	}
}
