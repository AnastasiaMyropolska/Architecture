//
//  ContentViewModel.swift
//  Architecture
//
//  Created by Anastasia Miropolskaja on 13.04.25.
//

import MapKit
import SwiftUI

@Observable class ContentViewModel {
	private var locationManager = LocationManager()
	var visibleRegion: MKCoordinateRegion?
	var visibleMarkers: [MKMapItem] = []//[ArtefactMapItem] = []
	var selectedMarker: MKMapItem?//ArtefactMapItem?

	func requestArtifacts() async {
		guard let visibleRegion else { return }
		
		let request = Request(region: visibleRegion)
		do {
			let artefacts = try await Parser(request: request).parse()
			visibleMarkers = artefacts.map {$0.convertToMapItem() }
		} catch {
			visibleMarkers = []
		}
	}
}
