//
//  CategoryDTO.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 05.06.26.
//

import Foundation

struct CategoryDTO: Decodable {
	let category_name: String
	let web_reference_wiki: URL
	let page_language: String
	let id: UInt16

	struct CategorySynonymDTO: Decodable {
		let lang: String
		let lang_name: String
		let web_reference_wiki: URL
		let id: UInt64
	}

	let synonyms: [CategorySynonymDTO]? // can be missing
}


