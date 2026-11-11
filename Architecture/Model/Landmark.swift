//
//  Landmark.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 21.03.26.
//

import Foundation
import CoreLocation

/// Presenatation level object representing architectural object shown on the map

struct Landmark: Identifiable, Equatable, Hashable { // use Hashable instead of MapSelectable

	let id: UInt64
	let location: CLLocationCoordinate2D
	/// scaled-down version of the landmark's image, suitable for showing in the UI
	let thumbnailURL: URL?
	let events: [HistoricalEvent]?
	let styleIndexes: [UInt16]
	/// keyed by language code
	private let localizedNames: [String: LocalizedName]
	/// language code of the landmark's own page; used when there is no entry for the user's language
	private let primaryLanguage: String
	var styles: [Style] = []

	/// entry for the user's preferred language, falling back to the landmark's own page language
	private var preferredLocalizedName: LocalizedName? {
		let userLanguage = Locale.preferredLanguages.first.flatMap { Locale(identifier: $0).language.languageCode?.identifier }
		if let userLanguage, let localizedName = localizedNames[userLanguage] {
			return localizedName
		}
		return localizedNames[primaryLanguage]
	}

	var localizedName: String? {
		preferredLocalizedName?.name
	}

	var localizedWebReference: URL? {
		preferredLocalizedName?.webReference
	}

	init(location: CLLocationCoordinate2D, id: UInt64, imageURL: URL?, events: [HistoricalEvent]? = [], styleIndexes: [UInt16], localizedNames: [String: LocalizedName], primaryLanguage: String) {
		self.location = location
		self.thumbnailURL = imageURL.map(Self.thumbnailURL(for:))
		self.events = events
		self.id = id
		self.styleIndexes = styleIndexes
		self.localizedNames = localizedNames
		self.primaryLanguage = primaryLanguage
	}

	/// Swaps a multi-megabyte Wikimedia Commons original for a scaled thumbnail; other URLs are unchanged.
	///
	/// Points straight at the CDN thumbnail (`/commons/thumb/a/ab/File.jpg/960px-File.jpg`) instead of going
	/// through `Special:FilePath`, which costs an extra redirect. 960 is one of Wikimedia's standard
	/// thumbnail widths, so it is more likely to be pre-rendered than an arbitrary width.
	private static func thumbnailURL(for imageURL: URL) -> URL {
		let thumbnailWidth = 960
		let originalPrefix = "/wikipedia/commons/"
		let path = imageURL.path(percentEncoded: true)
		let fileName = (path as NSString).lastPathComponent
		// Only raster formats keep their extension in thumbnail names (SVG, TIFF, PDF get a .png suffix).
		let rasterExtensions = ["jpg", "jpeg", "png", "gif"]
		guard imageURL.host() == "upload.wikimedia.org",
			  path.hasPrefix(originalPrefix),
			  !path.hasPrefix(originalPrefix + "thumb/"),
			  rasterExtensions.contains((fileName as NSString).pathExtension.lowercased()),
			  var components = URLComponents(url: imageURL, resolvingAgainstBaseURL: false) else {
			return imageURL
		}
		components.percentEncodedPath = originalPrefix + "thumb/" + path.dropFirst(originalPrefix.count)
			+ "/\(thumbnailWidth)px-" + fileName
		return components.url ?? imageURL
	}

    static func == (lhs: Landmark, rhs: Landmark) -> Bool {
		return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
		hasher.combine(id)
    }

	/// Name of a landmark in a single language, with a link to the corresponding wiki page
	struct LocalizedName: Hashable {
		let name: String
		let webReference: URL
	}

	struct HistoricalEvent {

		enum EventType {
			case constructionStarted
			case constructionCompleted
			case other
		}

		let eventType: EventType
		let eventStart: String
		let eventEnd: String
	}
}

