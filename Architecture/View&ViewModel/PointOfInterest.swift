//
//  PointOfInterest.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 21.03.26.
//

import Foundation
import CoreLocation

struct PointOfInterest: Identifiable, Equatable, Hashable { // use Hashable instead of MapSelectable
	let id = UUID() // it is needed to be used in ForEach.
	let location: CLLocationCoordinate2D
	let title: String?
	let URL: URL?
	let imageURL: URL?

    static func == (lhs: PointOfInterest, rhs: PointOfInterest) -> Bool {
		return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
		hasher.combine(id)
    }
}
