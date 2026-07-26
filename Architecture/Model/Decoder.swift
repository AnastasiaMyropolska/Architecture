//
//  Decoder.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 25.08.24.
//

import MapKit

enum NetworkingError: LocalizedError {
	case resourceNotFound
	case serverError
}

struct Decoder {

	private struct ResponseData: Decodable {
		var artefacts: [Artefact]
		var categories: [ArtefactCategory]
	}

	static func decode(data: Data) async throws -> ([Artefact], [ArtefactCategory]) {
		do {
			let decodedResponse = try JSONDecoder().decode(ResponseData.self, from: data)
			let artefacts = decodedResponse.artefacts
			let styles = decodedResponse.categories

			return (artefacts, styles)
		} catch let DecodingError.keyNotFound(key, context) {
			print("Missing key: \(key), \(context)")
		} catch let DecodingError.typeMismatch(type, context) {
			print("Type mismatch: \(type), \(context)")
		} catch {
			print(error)
		}

		return ([], [])
	}
}



