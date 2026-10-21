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
		var artefacts: [LandmarkDTO]
		var categories: [CategoryDTO]
	}

	static func decode(data: Data) async throws -> ([LandmarkDTO], [CategoryDTO]) {
		do {
			let decodedResponse = try JSONDecoder().decode(ResponseData.self, from: data)
			let landmarksDTOs = decodedResponse.artefacts
			let categoriesDTOs = decodedResponse.categories

			return (landmarksDTOs, categoriesDTOs)
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



