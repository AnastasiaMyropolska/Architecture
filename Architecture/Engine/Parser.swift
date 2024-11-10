//
//  Parser.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 25.08.24.
//

import Foundation
import MapKit

enum NetworkingError: LocalizedError {
	case resourceNotFound
	case serverError
}

struct Request {
	let region: MKCoordinateRegion // must be initiated with visible region on the map
}

struct Parser {

	private struct ResponseData: Decodable {
		var artefacts: [Artefact]
	}

	let request: Request // use region to request from server

	func parse() async throws -> [Artefact] {
		guard let url = Bundle.main.url(forResource: "20240824.0001", withExtension: "json") else {
			throw NetworkingError.resourceNotFound
		}

		let (data, responce) = try await URLSession.shared.data(from: url)

// enable once running on server
//		guard (responce as? HTTPURLResponse)?.statusCode == 200 else {
//			throw NetworkingError.serverError
//		}

		let artefacts = try JSONDecoder().decode(ResponseData.self, from: data).artefacts

		return Array(artefacts.prefix(5))
	}
}

