//
//  Category.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 05.06.26.
//

import Foundation

struct Category1: Decodable {
	let category_name: String
	let web_reference_wiki: URL
	let id: UInt16
}

extension Array where Element == Category1 {
	/// Builds a dictionary keyed by Category1.id with values of PoiCategory.
	/// If duplicate ids are encountered, the last one wins.
	func toPoiCategoryDictionary() -> [UInt16: POICategory] {
		Dictionary(self.map { ($0.id, POICategory.poiCategory(from: $0)) }, uniquingKeysWith: { _, new in new })
	}
}

