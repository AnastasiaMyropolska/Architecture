//
//  ArtefactCategoryToArchitecturalStyleBridge.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 26.07.26.
//

/// initialize ArchitecturalStyle from ArtefactCategory - connection point between Model layer and Presetnation layer

extension ArchitecturalStyle {
	static func create(from category: ArtefactCategory) -> Self {
		let style = ArchitecturalStyle(
			name: category.category_name,
			URL: category.web_reference_wiki,
			index: category.id)
		return style
	}
}

//extension Array where Element == ArtefactCategory {
//	/// Builds a dictionary keyed by ArtefactCategory.id with values of PoiCategory.
//	/// If duplicate ids are encountered, the last one wins.
//	func toPoiCategoryDictionary() -> [UInt16: ArchitecturalStyle] {
//		Dictionary(self.map { ($0.id, ArchitecturalStyle.create(from: $0)) }, uniquingKeysWith: { _, new in new })
//	}
//}
