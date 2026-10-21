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

	@ObservationIgnored
	private let landmarkLoader = LandmarkLoader()

	var visibleLandmarks: [Landmark] = []
	var styles: [Style] = []

	private var _selectedLandmark: Landmark?

	// The selected landmark, with its styles resolved once when it is selected
	var selectedLandmark: Landmark? {
		get {
			_selectedLandmark
		}
		set {
			var landmark = newValue
			landmark?.styles = styles.filter { newValue?.styleIndexes.contains($0.index) == true }
			_selectedLandmark = landmark
		}
	}

	func requestArtifacts(for region: MKCoordinateRegion) async {
		do {
			(visibleLandmarks, styles) = try await sendNewRequest(for: region)
		} catch is CancellationError {
			// Request was cancelled; ignore
		} catch {
			// TODO: handle error appropriately
		}
	}

	func sendNewRequest(for region: MKCoordinateRegion) async throws -> ([Landmark], [Style]) {
		// Cancel any previously running fire-and-forget task if present
		requestTask?.cancel()
		requestTask = nil

		// Debounce
		// debounce: do not execute each incoming task, execute at most one task in 400 milliseconds
		// Task.sleep() suspends an async task without making any thread unavailable
		try await Task.sleep(for: .milliseconds(400))
		try Task.checkCancellation()

		return try await landmarkLoader.landmarks(for: region)
	}
}
