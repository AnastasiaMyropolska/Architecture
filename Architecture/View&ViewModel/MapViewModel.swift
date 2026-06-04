//
//  MapViewModel.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 13.04.25.
//

import Observation
import MapKit

@MainActor
@Observable final class MapViewModel {

	@ObservationIgnored
	private var requestTask: Task<Void, Never>?

	var visiblePois: [PointOfInterest] = []
	var selectedPoi: PointOfInterest?

	func requestArtifacts(for region: MKCoordinateRegion) {

		requestTask?.cancel()

		// create cancellable task
		requestTask = Task { [weak self] in
			do {
				// debounce: do not execute each incoming task, execute at most one task in 400 milliseconds
				// Task.sleep() suspends an async task without making any thread unavailable
				try await Task.sleep(for: .milliseconds(400))

				try Task.checkCancellation()

				// parse in background, don't block main thread
				let data = try await Fetcher.fetchRemote(region: region)
				let artefacts = try await Decoder.decode(data: data)

				let pointsOfInterest = artefacts.map { PointOfInterest.poi(from: $0) }

				self?.visiblePois = pointsOfInterest

			} catch is CancellationError {
				// Task was cancelled - nothing to do
				return
			} catch {
				// Parsing failed - need to handle
				return
			}
		}
	}
}
