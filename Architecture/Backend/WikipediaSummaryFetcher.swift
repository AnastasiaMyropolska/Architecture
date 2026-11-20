//
//  WikipediaSummaryFetcher.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 18.11.26.
//

import Foundation

/// Fetches the intro text of a Wikipedia article through the public REST summary endpoint.
///
/// Stateless: every call goes to the network. See `WikipediaSummaryCache` for repeated lookups.
struct WikipediaSummaryFetcher {

	enum FetchingError: LocalizedError {
		case notAWikipediaArticle
		case serverError
	}

	private struct Summary: Decodable {
		let type: String
		let extract: String?
	}

	/// Returns the plain-text intro of the article the given link points to, in the language of the link's Wikipedia edition.
	/// Returns nil if the article has no usable intro (e.g. a disambiguation page).
	func fetchIntro(forArticle articleURL: URL) async throws -> String? {
		let request = try Self.summaryRequest(forArticle: articleURL)
		let (data, response) = try await URLSession.shared.data(for: request)

		guard (response as? HTTPURLResponse)?.statusCode == 200 else {
			throw FetchingError.serverError
		}

		let summary = try JSONDecoder().decode(Summary.self, from: data)
		guard summary.type == "standard", let extract = summary.extract, !extract.isEmpty else {
			return nil
		}

		return extract
	}

	/// `https://de.wikipedia.org/wiki/Title` -> `https://de.wikipedia.org/api/rest_v1/page/summary/Title`
	private static func summaryRequest(forArticle articleURL: URL) throws -> URLRequest {
		// lastPathComponent is percent-decoded, so it has to be encoded again for the new path
		let title = articleURL.lastPathComponent
		guard let host = articleURL.host(),
			  host.hasSuffix(".wikipedia.org"),
			  !title.isEmpty,
			  let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
			throw FetchingError.notAWikipediaArticle
		}

		var components = URLComponents()
		components.scheme = "https"
		components.host = host
		components.percentEncodedPath = "/api/rest_v1/page/summary/" + encodedTitle
		guard let url = components.url else {
			throw FetchingError.notAWikipediaArticle
		}

		var request = URLRequest(url: url)
		// Wikimedia asks API clients to identify themselves
		request.setValue("Architecture-iOS/1.0 (anastasiia@evehome.com)", forHTTPHeaderField: "User-Agent")
		return request
	}
}
