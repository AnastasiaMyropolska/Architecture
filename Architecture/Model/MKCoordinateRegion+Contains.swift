//
//  MKCoordinateRegion+Contains.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 21.03.26.
//

import MapKit

extension MKCoordinateRegion {
	func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
		let regionSpan = self.span

		let topLeft = MKMapPoint(CLLocationCoordinate2D(
			latitude: center.latitude + regionSpan.latitudeDelta / 2,
			longitude: center.longitude - regionSpan.longitudeDelta / 2
		))

		let bottomRight = MKMapPoint(CLLocationCoordinate2D(
			latitude: center.latitude - regionSpan.latitudeDelta / 2,
			longitude: center.longitude + regionSpan.longitudeDelta / 2
		))

		let mapRect = MKMapRect(
			origin: MKMapPoint(x: min(topLeft.x, bottomRight.x), y: min(topLeft.y, bottomRight.y)),
			size: MKMapSize(width: abs(topLeft.x - bottomRight.x), height: abs(topLeft.y - bottomRight.y))
		)

		let point = MKMapPoint(coordinate)
		return mapRect.contains(point)
	}
}
