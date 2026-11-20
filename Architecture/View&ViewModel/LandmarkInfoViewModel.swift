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

	/// Intro text of the landmark's wiki page; nil until `loadDescription()` finishes, and if there is none or it could not be loaded
	private(set) var description: String?

	func loadDescription() async {
		let loadedDescription = await landmark.description
		// a cancelled load comes back as nil (see `Landmark.description`) and is not a result
		guard !Task.isCancelled else { return }
		description = loadedDescription
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

	/// "in 834", "from 834 to 850", "Started in 834" or "Finished in 850" (a lone completion range "834 – 850" reads "from 834 to 850"); nil when neither date is known
	var dates: String? {
		switch (started, completed) {
		case let (started?, completed?): return started == completed ? "in \(started)" : "from \(started) to \(completed)"
		case let (started?, nil): return "Started in \(started)"
		case let (nil, completed?):
			// a completion given as a range ("834 – 850") reads as a span rather than a finish date
			let bounds = completed.components(separatedBy: " – ")
			return bounds.count == 2 ? "from \(bounds[0]) to \(bounds[1])" : "Finished in \(completed)"
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

