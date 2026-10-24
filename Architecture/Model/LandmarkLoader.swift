//
//  LandmarkLoader.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 21.10.26.
//

import MapKit

/// Loads landmarks and their styles for a region, hiding fetching, decoding and mapping from the presentation layer.
struct LandmarkLoader {

	func landmarks(for region: MKCoordinateRegion) async throws -> ([Landmark], [Style]) {
		// The simulator uses the bundled JSON, a real device talks to the server
		#if targetEnvironment(simulator)
		let data = try await ServerDataFetcher.fetchLocal()
		#else
		let data = try await ServerDataFetcher.fetchRemote(region: region)
		#endif
		let (landmarkDTOs, categoryDTOs) = try await DTODecoder.decode(data: data)

		let landmarks = landmarkDTOs.map { Landmark.create(from: $0) }
		let styles = categoryDTOs.map { Style.create(from: $0) }

		return (landmarks, styles)
	}
}
