//
//  Fetcher.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 21.03.26.
//

import Foundation
import MapKit

struct Fetcher {

	static func fetchLocal(region: MKCoordinateRegion) async throws -> Data {
		guard let url = Bundle.main.url(forResource: "20240824.0001_small", withExtension: "json") else {
			throw NetworkingError.resourceNotFound
		}

		let (data, responce) = try await URLSession.shared.data(from: url)

		if let httpResponce = responce as? HTTPURLResponse, !(200..<300 ~= httpResponce.statusCode) {
			// todo: retry for 5xx network errors
			throw NetworkingError.serverError
		}

		return data
	}

	struct ArtefactRequest: Codable {
		let token: String
		let thema: String
		let longitude: Double
		let latitude: Double
		let precision: Double
		let lookAroundVersion: String
		let calltype: String
	}
	
	static func fetchRemote(region: MKCoordinateRegion) async throws -> Data {
		guard let url = URL(string: "https://apalladio.org/architecture-api/supplyArtefacts") else {
			throw NetworkingError.resourceNotFound
		}

		let requestBody = ArtefactRequest(
			token: "pk.eyJ1IjoibXlyb3BvbHNreWkiLCJhIjoiY2t1dHVibDZvMmZlNDJwcDFwMTI3ZjU0dyJ9.J_kmeuSJGKwoKiqQXVfFAQ",
			thema: "Architecture",
			longitude: region.center.longitude,
			latitude: region.center.latitude,
			precision: max(region.span.latitudeDelta, region.span.longitudeDelta),
			lookAroundVersion: "1.0.0",
			calltype: "iOS"
		)

		let requestBodyJson = try JSONEncoder().encode(requestBody)

		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = requestBodyJson

		let (data, response) = try await URLSession.shared.data(for: request)

		guard (response as? HTTPURLResponse)?.statusCode == 200 else {
			throw NetworkingError.serverError
		}

		return data
	}
}

