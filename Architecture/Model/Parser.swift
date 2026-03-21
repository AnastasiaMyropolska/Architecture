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
	}

	static func decode(data: Data, region: MKCoordinateRegion) async throws -> [Artefact] {
		do {
			let decodedResponse = try JSONDecoder().decode(ResponseData.self, from: data)
			let artefacts = decodedResponse.artefacts
			let visibleArtefacts = artefacts.filter{ region.contains( $0.artefactsLocation.location) }
			return visibleArtefacts
		} catch let DecodingError.keyNotFound(key, context) {
			print("Missing key: \(key), \(context)")
		}
		catch let DecodingError.typeMismatch(type, context) {
			print("Type mismatch: \(type), \(context)")
		}
		catch {
			print(error)
		}

		return []
	}


	static func decode(data: Data) async throws -> [Artefact] {
		do {
			let decodedResponse = try JSONDecoder().decode(ResponseData.self, from: data)
			let artefacts = decodedResponse.artefacts
			return artefacts
		} catch let DecodingError.keyNotFound(key, context) {
			print("Missing key: \(key), \(context)")
		} catch let DecodingError.typeMismatch(type, context) {
			print("Type mismatch: \(type), \(context)")
		}
		catch {
			print(error)
		}

		return []
	}
}



