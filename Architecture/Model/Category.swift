//
//  Category.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 05.06.26.
//

import Foundation

struct Category: Decodable {
	let category_name: String
	let web_reference_wiki: URL
	let id: UInt16
}
