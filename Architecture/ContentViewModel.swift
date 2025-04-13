//
//  ContentViewModel.swift
//  Architecture
//
//  Created by Anastasia Miropolskaja on 13.04.25.
//

import MapKit
import SwiftUICore

@Observable class ContentViewModel {
	private var locationManager = LocationManager()
	var visibleRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.1967608, longitude: 11.4132661), span: MKCoordinateSpan(latitudeDelta: 15, longitudeDelta: 15)) // has to be @State, otherwise not possible to change in onMapCameraChange // TODO: wft is this, why hardcoded? we should use user's location
	var visibleMarkers: [MKMapItem] = []//[ArtefactMapItem] = []
	var selectedMarker: MKMapItem?//ArtefactMapItem?

	func requestArtifacts() async {
		let request = Request(region: visibleRegion)
		do {
			let artefacts = try await Parser(request: request).parse()
			visibleMarkers = artefacts.map {$0.convertToMapItem() }
		} catch {
			visibleMarkers = []
		}
	}
}
