//
//  ContentViewModel.swift
//  Architecture
//
//  Created by Anastasia Miropolskaja on 13.04.25.
//

import MapKit
import SwiftUI

@MainActor
@Observable class ContentViewModel {

	@ObservationIgnored
	private var requestTask: Task<Void, Never>?

	var visibleMarkers: [MKMapItem] = []//[ArtefactMapItem] = []
	var selectedMarker: MKMapItem?//ArtefactMapItem?

	func requestArtifacts(for region: MKCoordinateRegion) {
		requestTask?.cancel()
		requestTask = Task { [weak self] in
			let request = Request(region: region)
			do {
				// background work
				let artefacts = try await Parser(request: request).parse()
				let markers = artefacts.map { $0.convertToMapItem() }

				self?.visibleMarkers = markers
			} catch {
				self?.visibleMarkers = []
			}
		}
	}
}
