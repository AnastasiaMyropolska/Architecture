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

	/// Waits for the first location fix, so the view knows when the initial request can be made.
	/// Returns false if there will be no fix (e.g. location access is denied).
	func waitForFirstLocationFix() async -> Bool {
		do {
			// Taking only the first fix: returning from the loop ends the location updates
			for try await update in CLLocationUpdate.liveUpdates() {
				if update.authorizationDenied || update.authorizationDeniedGlobally {
					// Without location there is no initial request; landmarks load when the user moves the map
					return false
				}

				guard update.location != nil else {
					// No fix yet (e.g. the authorization request is still in progress)
					continue
				}

				return true
			}
		} catch {
			// TODO: handle error appropriately
		}
		return false
	}

	func requestArtifacts(for region: MKCoordinateRegion) {
		// Cancel the previously running task, so only the latest request survives the debounce
		requestTask?.cancel()

		// The task is stored, so the next call can cancel it
		requestTask = Task {
			do {
				(visibleLandmarks, styles) = try await sendNewRequest(for: region)
			} catch is CancellationError {
				// Request was cancelled; ignore
			} catch {
				// TODO: handle error appropriately
			}
		}
	}

	func sendNewRequest(for region: MKCoordinateRegion) async throws -> ([Landmark], [Style]) {
		// Debounce
		// debounce: do not execute each incoming task, execute at most one task in 400 milliseconds
		// Task.sleep() suspends an async task without making any thread unavailable
		try await Task.sleep(for: .milliseconds(400))
		try Task.checkCancellation()

		let result = try await landmarkLoader.landmarks(for: region)

		// Don't let a stale response overwrite the result of a newer request
		try Task.checkCancellation()
		return result
	}
}
