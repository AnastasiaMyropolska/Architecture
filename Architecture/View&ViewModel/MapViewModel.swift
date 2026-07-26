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

	// todo: improve architecturalStyles calculations, i think this 2 properties are not needed
	//@ObservationIgnored
	private var _selectedPoi: PointOfInterest?
	
	// Computed property returning a copy of the selected POI with its architecturalStyles filtered and assigned
	var selectedPoi: PointOfInterest? {
		get {
			guard var poi = _selectedPoi else { return nil }
			poi.architecturalStyles = architecturalStyles.filter { poi.architecturalStyleIndexes.contains($0.index) }
			return poi
		}
		set {
			_selectedPoi = newValue
		}
	}

	var architecturalStyles: [ArchitecturalStyle] = []

	func requestArtifacts(for region: MKCoordinateRegion) async {
		do {
			(visiblePois, architecturalStyles) = try await sendNewRequest(for: region)
		} catch is CancellationError {
			// Request was cancelled; ignore
		} catch {
			// TODO: handle error appropriately
		}
	}

	func sendNewRequest(for region: MKCoordinateRegion) async throws -> ([PointOfInterest], [ArchitecturalStyle]) {
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

		let pointsOfInterest = artefacts.map { PointOfInterest.create(from: $0) }
		let architecturalStyles = categories.map { ArchitecturalStyle.create(from: $0) }

		return (pointsOfInterest, architecturalStyles)
	}
}
