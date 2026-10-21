//
//  CategoryDTOToModelBridge.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 26.07.26.
//

/// initialize Style from CategoryDTO - connection point between Model layer and Presetnation layer

extension Style {
	static func create(from category: CategoryDTO) -> Self {
		let style = Style(
			name: category.category_name,
			URL: category.web_reference_wiki,
			index: category.id)
		return style
	}
}

//extension Array where Element == CategoryDTO {
//	/// Builds a dictionary keyed by CategoryDTO.id with values of PoiCategory.
//	/// If duplicate ids are encountered, the last one wins.
//	func toPoiCategoryDictionary() -> [UInt16: Style] {
//		Dictionary(self.map { ($0.id, Style.create(from: $0)) }, uniquingKeysWith: { _, new in new })
//	}
//}
