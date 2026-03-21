//
//  ArtefactMapItem.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 21.03.26.
//

import MapKit

struct ArtefactMapItem: Identifiable, Hashable, Equatable {
	let id = UUID()
	let mapItem: MKMapItem
	let imageURL: URL?
    
    static func == (lhs: ArtefactMapItem, rhs: ArtefactMapItem) -> Bool {
        lhs.mapItem.placemark.coordinate.latitude == rhs.mapItem.placemark.coordinate.latitude &&
        lhs.mapItem.placemark.coordinate.longitude == rhs.mapItem.placemark.coordinate.longitude &&
        lhs.mapItem.name == rhs.mapItem.name &&
        lhs.mapItem.url == rhs.mapItem.url
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(mapItem.placemark.coordinate.latitude)
        hasher.combine(mapItem.placemark.coordinate.longitude)
        hasher.combine(mapItem.name)
        hasher.combine(mapItem.url)
    }
}
