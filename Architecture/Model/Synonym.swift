//
//  Synonym.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 26.10.26.
//

import Foundation

/// Name of a landmark in another language, with a link to the corresponding wiki page
struct Synonym {
	let id: UInt64
	let languageCode: String
	let name: String
	let URL: URL

	init(from synonymDTO: LandmarkDTO.SynonymDTO) {
		self.id = synonymDTO.id
		self.languageCode = synonymDTO.lang
		self.name = synonymDTO.lang_name
		self.URL = synonymDTO.web_reference_wiki
	}
}
