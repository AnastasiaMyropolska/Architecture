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

		// for now filter out here; once requested from server using region, it will be filtered on a server
		let visibleArtefacts = artefacts.filter{ request.region.contains( $0.artefactsLocation.location) }

		return Array(visibleArtefacts/*.prefix(5)*/)

		// todo: try to use async sequence
//		let result: (bytes: URLSession.AsyncBytes, response: URLResponse) = try await URLSession.shared.bytes(from: url, delegate: nil)
//		for try await line in result.bytes.lines {
//		  let artefacts = try JSONDecoder().decode(ResponseData.self, from: Data(line.utf8))
//		  await updateFavoriteCount(with: photoMetadata) // 👈🏻 need to execute in the main actor
//		}
// don't know if this will work and how to handle async array in ContentView. This should return not array of bytes, but array of artifacts


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

