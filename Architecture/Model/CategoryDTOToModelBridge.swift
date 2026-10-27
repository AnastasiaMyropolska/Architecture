//
//  CategoryDTOToModelBridge.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 26.07.26.
//

/// initialize Style from CategoryDTO - connection point between Model layer and Presetnation layer

extension Style {
	static func create(from category: CategoryDTO) -> Self {
		// the category's own page language goes first and wins over a synonym with the same language code
		var localizedStylesNames = [category.page_language: LocalizedStyleName(name: category.category_name, webReference: category.web_reference_wiki)]
		for synonym in category.synonyms ?? [] where localizedStylesNames[synonym.lang] == nil {
			localizedStylesNames[synonym.lang] = LocalizedStyleName(name: synonym.lang_name, webReference: synonym.web_reference_wiki)
		}

		let style = Style(
			index: category.id,
			localizedStylesNames: localizedStylesNames,
			primaryLanguage: category.page_language)
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
