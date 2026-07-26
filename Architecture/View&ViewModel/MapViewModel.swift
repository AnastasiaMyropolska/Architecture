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

	func requestArtifacts(for region: MKCoordinateRegion) async {
		do {
			visiblePois = try await sendNewRequest(for: region)
		} catch is CancellationError {
			// Request was cancelled; ignore
		} catch {
			// TODO: handle error appropriately
		}
	}

	func sendNewRequest(for region: MKCoordinateRegion) async throws -> [PointOfInterest] {
		// Cancel any previously running fire-and-forget task if present
		requestTask?.cancel()
		requestTask = nil

		// Debounce
		// debounce: do not execute each incoming task, execute at most one task in 400 milliseconds
		// Task.sleep() suspends an async task without making any thread unavailable
		try await Task.sleep(for: .milliseconds(400))
		try Task.checkCancellation()

		// Fetch and decode
		let data = try await Fetcher.fetchRemote(region: region)
		let (artefacts, categories) = try await Decoder.decode(data: data)

		let pointsOfInterest = artefacts.map { PointOfInterest.poi(from: $0) }
		let _ = categories.toPoiCategoryDictionary()

		return pointsOfInterest
	}
}
