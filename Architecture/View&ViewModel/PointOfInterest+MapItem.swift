//
//  PointOfInterest+MapItem.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 09.04.26.
//

import MapKit

extension PointOfInterest {
	// todo: is this efficient? move to extension, remove MapKit reference
	func mapItem() -> MKMapItem {
		return MKMapItem(placemark: MKPlacemark(coordinate: location))
	}
}
