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

	var visibleLandmarks: [Landmark] = []

	// todo: improve styles calculations, i think this 2 properties are not needed
	//@ObservationIgnored
	private var _selectedLandmark: Landmark?
	
	// Computed property returning a copy of the selected landmark with its styles filtered and assigned
	var selectedLandmark: Landmark? {
		get {
			guard var landmark = _selectedLandmark else {
				return nil
			}
			landmark.styles = styles.filter { landmark.styleIndexes.contains($0.index) }
			return landmark
		}
		set {
			_selectedLandmark = newValue
		}
	}

	var styles: [Style] = []

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

		// Fetch and decode
		let data = try await Fetcher.fetchLocal(region: region)
		let (landmarkDTOs, categories) = try await Decoder.decode(data: data)

		let landmarks = landmarkDTOs.map { Landmark.create(from: $0) }
		let styles = categories.map { Style.create(from: $0) }

		return (landmarks, styles)
	}
}
