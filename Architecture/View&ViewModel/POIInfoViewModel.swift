//
//  POIInfoViewModel.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 09.04.26.
//

import Observation
import Foundation

@MainActor
@Observable final class POIInfoViewModel {
	let poi: PointOfInterest

	init(poi: PointOfInterest) {
		self.poi = poi
	}

	var title: String {
		poi.title
	}

	var category: String {
		return poi.categories.joined(separator: ", ")
	}

	var imageURL: URL? {
		poi.imageURL
	}
}

