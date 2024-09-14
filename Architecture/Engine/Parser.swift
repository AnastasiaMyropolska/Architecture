//
//  Parser.swift
//  Maps
//
//  Created by Anastasia Myropolska on 25.08.24.
//

import Foundation
import MapKit

struct Parser {

	private struct ResponseData: Decodable {
		var artefacts: [Artefact]
	}

	struct Artefact: Decodable {
		struct ArtefactsLocation: Decodable {
			var location: CLLocationCoordinate2D {
				return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
			}
			
			let longitude: Double
			let latitude: Double
			let id: UInt64 // ? how long a the ids in json file?
		}

		let artefacts_name: String
		let artefactsLocation: ArtefactsLocation
	}

	func parse() -> [Artefact]? {
		if let url = Bundle.main.url(forResource: "20240824.0001", withExtension: "json") {
			do {
				let data = try Data(contentsOf: url)
				let decoder = JSONDecoder()
				let decodedObject = try decoder.decode(ResponseData.self, from: data)
				return decodedObject.artefacts
			} catch {
				print("error:\(error)")
			}
		}
		return nil
	}
}
