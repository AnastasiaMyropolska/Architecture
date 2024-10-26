//
//  Parser.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 25.08.24.
//

import Foundation

struct Parser {
	
	private struct ResponseData: Decodable {
		var artefacts: [Artefact]
	}
	
	func parse() async -> [Artefact]? {
		if let url = Bundle.main.url(forResource: "20240824.0001", withExtension: "json") {
			do {
				let (data, resp) = try await URLSession.shared.data(from: url)
				//						guard (resp as? HTTPURLResponse)?.statusCode == 200 else {
				//							print("bad response")
				//							return
				//						}
				let decoder = JSONDecoder()
				let decodedObject = try decoder.decode(ResponseData.self, from: data) // synchronous!
				return decodedObject.artefacts
			} catch {
				// catch any try-error from do {}
				print("error:\(error)")
			}
		}
		return nil
	}
}

