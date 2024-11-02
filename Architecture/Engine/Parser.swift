//
//  Parser.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 25.08.24.
//

import Foundation

enum NetworkingError: LocalizedError {
	case resourceNotFound
	case serverError
}

// do we need an actor here or URLSession.shared.data() is automatically executed in background?
struct Parser {

	private struct ResponseData: Decodable {
		var artefacts: [Artefact]
	}
	
	func parse() async throws -> [Artefact] {
		guard let url = Bundle.main.url(forResource: "20240824.0001", withExtension: "json") else {
			throw NetworkingError.resourceNotFound
		}

		let (data, responce) = try await URLSession.shared.data(from: url)

// enable once running on server
//		guard (responce as? HTTPURLResponse)?.statusCode == 200 else {
//			throw NetworkingError.serverError
//		}

		return try JSONDecoder().decode(ResponseData.self, from: data).artefacts
	}
}

