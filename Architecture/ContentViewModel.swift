//
//  ContentViewModel.swift
//  Architecture
//
//  Created by Anastasia Miropolskaja on 13.04.25.
//

import MapKit

@MainActor
@Observable class ContentViewModel {

	@ObservationIgnored
	private var requestTask: Task<Void, Never>?

	var visibleMarkers: [MKMapItem] = []//[ArtefactMapItem] = []
	var selectedMarker: MKMapItem?//ArtefactMapItem?

	func requestArtifacts(for region: MKCoordinateRegion) {

		requestTask?.cancel()

		requestTask = Task { [weak self] in
			do {
				// debounce: do not execute each incoming task, execute at most one task in 400 milliseconds
				// Task.sleep() suspends an async task without making any thread unavailable
				try await Task.sleep(for: .milliseconds(400))

				try Task.checkCancellation()

				let request = Request(region: region)

				let artefacts = try await Parser(request: request).parse()
				let markers = artefacts.map { $0.convertToMapItem() }

				self?.visibleMarkers = markers

			} catch is CancellationError {
				// expected - ignore
				return
			} catch {
				return
			}
		}
	}
}
