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

// todo: enable once running on server
//		guard (responce as? HTTPURLResponse)?.statusCode == 200 else {
//			throw NetworkingError.serverError
//		}

		let artefacts = try JSONDecoder().decode(ResponseData.self, from: data).artefacts

		return Array(artefacts.prefix(5))

		// todo: try to use async sequence
//		let result: (bytes: URLSession.AsyncBytes, response: URLResponse) = try await URLSession.shared.bytes(from: url, delegate: nil)
//		for try await line in result.bytes.lines {
//		  let artefacts = try JSONDecoder().decode(ResponseData.self, from: Data(line.utf8))
//		  await updateFavoriteCount(with: photoMetadata) // 👈🏻 need to execute in the main actor
//		}
// don't know if this will work and how to handle async array in ContentView. This should return not array of bytes, but array of artifacts


	}
}

