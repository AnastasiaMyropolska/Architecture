//
//  LookAroundViewModel.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.11.26.
//

import Observation
import MapKit

/// Look Around is kept out of `LandmarkViewModel` on purpose: `MKLookAroundScene` is a MapKit type,
/// and a separate view model means `LandmarkViewModel` doesn't have to import MapKit
@MainActor
@Observable final class LookAroundViewModel {
	private let landmark: Landmark

	init(landmark: Landmark) {
		self.landmark = landmark
	}

	/// Look Around scene at the landmark; nil until `loadScene()` finishes, and if Look Around is not available there
	private(set) var scene: MKLookAroundScene?

	var isPresented = false

	/// Whether Look Around can be offered for the landmark
	var isAvailable: Bool {
		scene != nil
	}

	func loadScene() async {
		let loadedScene = await landmark.lookAroundScene()
		// a cancelled load comes back as nil and is not a result
		guard !Task.isCancelled else { return }
		scene = loadedScene
	}

	func present() {
		isPresented = true
	}
}
