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

	var styles: [String] {
		landmark.styles.compactMap { $0.localizedName }
	}

	var started: String? {
		dateText(for: .constructionStarted)
	}

	var completed: String? {
		dateText(for: .constructionCompleted)
	}

	var sourceURL: URL? {
		landmark.localizedWebReference
	}

	var imageURL: URL? {
		landmark.imageURL
	}

	/// "834" or "834 – 850"; nil when the landmark has no such event or the dates are blank
	private func dateText(for type: Landmark.HistoricalEvent.EventType) -> String? {
		guard let event = landmark.events?.first(where: { $0.eventType == type }) else { return nil }
		let start = event.eventStart.trimmingCharacters(in: .whitespaces)
		let end = event.eventEnd.trimmingCharacters(in: .whitespaces)
		switch (start.isEmpty, end.isEmpty) {
		case (true, true): return nil
		case (false, true): return start
		case (true, false): return end
		case (false, false): return start == end ? start : "\(start) – \(end)"
		}
	}
}

