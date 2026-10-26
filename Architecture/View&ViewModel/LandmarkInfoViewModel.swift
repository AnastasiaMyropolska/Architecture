//
//  LandmarkInfoViewModel.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 09.04.26.
//

import Observation
import Foundation

@MainActor
@Observable final class LandmarkInfoViewModel {
	private let landmark: Landmark

	init(landmark: Landmark) {
		self.landmark = landmark
	}

	var title: String {
		landmark.localizedName ?? ""
	}

	var category: String {
		landmark.styles.map { $0.name }.joined(separator: ", ")
	}

	var sourceURL: URL? {
		landmark.localizedWebReference
	}

	var imageURL: URL? {
		landmark.imageURL
	}
}

