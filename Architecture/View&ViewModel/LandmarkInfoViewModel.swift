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

	var landmarkID: Landmark.ID {
		landmark.id
	}

	var title: String {
		landmark.localizedName ?? ""
	}

	/// Style names without the wiki "Category:" prefix and " - Wikipedia" suffix, if present
	var styles: [String] {
		landmark.styles.compactMap { $0.localizedName }.map { name in
			var name = name
			if name.hasPrefix("Category:") {
				name.removeFirst("Category:".count)
			}
			if name.hasSuffix(" - Wikipedia") {
				name.removeLast(" - Wikipedia".count)
			}
			return name.trimmingCharacters(in: .whitespaces)
		}
	}

	/// "Gustave Eiffel" or "A, B"; nil when the landmark has no known author
	var authors: String? {
		landmark.authors.isEmpty ? nil : landmark.authors.formatted(.list(type: .and, width: .narrow))
	}

	func openDirections() {
		landmark.openDirections()
	}

	var started: String? {
		dateText(for: .constructionStarted)
	}

	var completed: String? {
		dateText(for: .constructionCompleted)
	}

	/// "834 – 850" built from the start and completion dates; nil when neither is known
	var dates: String? {
		switch (started, completed) {
		case let (started?, completed?): return started == completed ? started : "\(started) – \(completed)"
		case let (started?, nil): return "from \(started)"
		case let (nil, completed?): return "until \(completed)"
		case (nil, nil): return nil
		}
	}

	var sourceURL: URL? {
		landmark.localizedWebReference
	}

	var imageURL: URL? {
		landmark.thumbnailURL
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

