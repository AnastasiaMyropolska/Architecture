//
//  DTODecoder.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 25.08.24.
//

import Foundation

struct DTODecoder {

	/// Wraps an array element so that a malformed entry decodes to nil (and is logged) instead of failing the whole array.
		/// "Lossy" because invalid entries are dropped.
		private struct Lossy<Element: Decodable>: Decodable {
			let value: Element?

			init(from decoder: Decoder) throws {
				do {
					value = try Element(from: decoder)
				} catch {
					print("Skipping malformed \(Element.self) entry: \(error)")
					value = nil
				}
			}
		}

		private struct ResponseData: Decodable {
		var artefacts: [Lossy<LandmarkDTO>]
		var categories: [Lossy<CategoryDTO>]
	}

	static func decode(data: Data) async throws -> ([LandmarkDTO], [CategoryDTO]) {
		do {
			let decodedResponse = try JSONDecoder().decode(ResponseData.self, from: data)
			let landmarksDTOs = decodedResponse.artefacts.compactMap(\.value)
			let categoriesDTOs = decodedResponse.categories.compactMap(\.value)

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



