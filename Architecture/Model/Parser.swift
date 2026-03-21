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

		do {
			let decodedResponse = try JSONDecoder().decode(ResponseData.self, from: data)
			let artefacts = decodedResponse.artefacts
			let visibleArtefacts = artefacts.filter{ request.region.contains( $0.artefactsLocation.location) }
			return Array(visibleArtefacts/*.prefix(5)*/)
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

	struct ArtefactRequest: Codable {
		let token: String
		let thema: String
		let longitude: Double
		let latitude: Double
		let precision: Double
		let lookAroundVersion: String
		let calltype: String
	}

	func parseRemote() async throws -> [Artefact] {
		guard let url = URL(string: "https://apalladio.org/architecture-api/supplyArtefacts") else {
			throw NetworkingError.resourceNotFound
		}


		let requestBody = ArtefactRequest(
			token: "pk.eyJ1IjoibXlyb3BvbHNreWkiLCJhIjoiY2t1dHVibDZvMmZlNDJwcDFwMTI3ZjU0dyJ9.J_kmeuSJGKwoKiqQXVfFAQ",
			thema: "Architecture",
			longitude: request.region.center.longitude,
			latitude: request.region.center.latitude,
			precision: 0.1,
			lookAroundVersion: "3.0.0",
			calltype: "web"
		)

		let jsonData = try JSONEncoder().encode(requestBody)

//		guard let url1 = Bundle.main.url(forResource: "request", withExtension: "json") else {
//			throw NetworkingError.resourceNotFound
//		}
		//let (data1, responce1) = try await URLSession.shared.data(from: url1)

		// 3. Create URLRequest
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.httpBody = jsonData

		let (data, response) = try await URLSession.shared.data(for: request)

		// Optional: check HTTP status code
		if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
			throw URLError(.badServerResponse)
		}

		do {
			let decodedResponse = try JSONDecoder().decode(ResponseData.self, from: data)
			let artefacts = decodedResponse.artefacts
			//let visibleArtefacts = artefacts.filter{ request.region.contains( $0.artefactsLocation.location) }
			return artefacts
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
}

extension MKCoordinateRegion {
	func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
		let regionSpan = self.span

		let topLeft = MKMapPoint(CLLocationCoordinate2D(
			latitude: center.latitude + regionSpan.latitudeDelta / 2,
			longitude: center.longitude - regionSpan.longitudeDelta / 2
		))

		let bottomRight = MKMapPoint(CLLocationCoordinate2D(
			latitude: center.latitude - regionSpan.latitudeDelta / 2,
			longitude: center.longitude + regionSpan.longitudeDelta / 2
		))

		let mapRect = MKMapRect(
			origin: MKMapPoint(x: min(topLeft.x, bottomRight.x), y: min(topLeft.y, bottomRight.y)),
			size: MKMapSize(width: abs(topLeft.x - bottomRight.x), height: abs(topLeft.y - bottomRight.y))
		)

		let point = MKMapPoint(coordinate)
		return mapRect.contains(point)
	}
}

