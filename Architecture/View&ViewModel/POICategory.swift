//
//  POICategory.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 06.06.26.
//

import Foundation

struct POICategory {
	let name: String
	let URL: URL
}

extension POICategory {
	static func poiCategory(from category: Category1) -> Self {

		let poiCategory = POICategory(
			name: category.category_name,
			URL: category.web_reference_wiki)
		return poiCategory
	}
}
