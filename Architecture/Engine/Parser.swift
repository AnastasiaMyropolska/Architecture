//
//  Parser.swift
//  Maps
//
//  Created by Anastasia Myropolska on 25.08.24.
//

import Foundation
import MapKit

//struct BlogPost: Decodable {
//	enum Category: String, Decodable {
//		case swift, combine, debugging, xcode
//	}
//
//	let title: String
//	let url: URL
//	let category: Category
//	let views: Int
//}

struct Parser {

	struct Artefact: Decodable {
		struct ArtefactsLocation: Decodable {
			let location: CLLocationCoordinate2D

			init(from: any Decoder) throws {
				location = CLLocationCoordinate2D(latitude: 48.1376373, longitude: 11.5771745)
			}
		}

		let artefacts_name: String
		let artefactsLocation: ArtefactsLocation
	}

	func parse() {
		if let path = Bundle.main.path(forResource: "20240824.0001", ofType: "json") {
			do {
				  let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
				  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
				if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let artefacts = jsonResult["artefacts"] as? Array<Dictionary<String, AnyObject>> {
					//if let artefact = artefacts[0] as? Artefact {
						print(artefacts[0])
					//}
				  }
			  } catch {
				   // handle error
			  }
		}
	}
}
