//
//  PointOfInterest.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 21.03.26.
//

import Foundation
import CoreLocation

struct PointOfInterest: Identifiable, Hashable, Equatable {
	let id = UUID() // is it needed?
	let location: CLLocationCoordinate2D
	let title: String?
	let URL: URL?
	let imageURL: URL?

    static func == (lhs: PointOfInterest, rhs: PointOfInterest) -> Bool {
        lhs.location.latitude == rhs.location.latitude &&
        lhs.location.longitude == rhs.location.longitude &&
        lhs.title == rhs.title &&
		lhs.URL == rhs.URL
    }

    func hash(into hasher: inout Hasher) {
//        hasher.combine(mapItem.placemark.coordinate.latitude)
//        hasher.combine(mapItem.placemark.coordinate.longitude)
//        hasher.combine(mapItem.name)
//        hasher.combine(mapItem.url)
    }
}
