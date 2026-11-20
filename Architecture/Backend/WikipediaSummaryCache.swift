//
//  WikipediaSummaryCache.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.11.26.
//

import Foundation

/// In-memory cache in front of `WikipediaSummaryFetcher`, so a recently read article is not requested again.
///
/// Holds at most `capacity` articles; when full, the least recently used one is evicted.
///
/// Why a cache: `Landmark.description` is computed on every read, and the same landmark is read again whenever
/// the user reopens it. Without a cache each of those reads would be a network request for text that has not changed.
///
/// Why it is not stored in `Landmark` itself:
/// - `MapViewModel` replaces all landmarks with freshly built values on every request, so a description stored
///   on a landmark would be lost as soon as the user moves the map. This cache is keyed by article URL
///   and does not depend on the landmark values being kept.
/// - `Landmark` is an immutable value type that is equal to another landmark with the same `id`. A description
///   filled in later would be neither visible to equality checks nor shared between the copies of the landmark
///   (e.g. the one in the visible list and the selected one).
/// - The description depends on the user's language, so it is not an intrinsic property of the landmark
///   like its authors or location. It is also needed only for the one landmark being opened, so loading it
///   for every landmark on the map would mean many unnecessary requests.
actor WikipediaSummaryCache {

	static let shared = WikipediaSummaryCache(fetcher: WikipediaSummaryFetcher())

	private let fetcher: WikipediaSummaryFetcher
	private let capacity: Int

	/// intro texts already fetched, keyed by article URL
	private var cache: [URL: String] = [:]

	/// cached article URLs, least recently used first
	private var usageOrder: [URL] = []

	init(fetcher: WikipediaSummaryFetcher, capacity: Int = 20) {
		self.fetcher = fetcher
		self.capacity = capacity
	}

	/// Returns the cached intro of the article, fetching it first if it is not cached yet.
	/// Only successful results are cached: a failure or a nil result (no usable intro) is requested again on the next call.
	func intro(forArticle articleURL: URL) async throws -> String? {
		if let cached = cache[articleURL] {
			markAsRecentlyUsed(articleURL)
			return cached
		}

		let intro = try await fetcher.fetchIntro(forArticle: articleURL)
		if let intro {
			store(intro, forArticle: articleURL)
		}
		return intro
	}

	private func store(_ intro: String, forArticle articleURL: URL) {
		cache[articleURL] = intro
		markAsRecentlyUsed(articleURL)

		// At most `capacity` entries, so a single eviction is enough; the loop also covers a capacity of 0
		while usageOrder.count > capacity {
			cache[usageOrder.removeFirst()] = nil
		}
	}

	private func markAsRecentlyUsed(_ articleURL: URL) {
		// the list is as short as the capacity, so a linear search is fine
		usageOrder.removeAll { $0 == articleURL }
		usageOrder.append(articleURL)
	}
}
