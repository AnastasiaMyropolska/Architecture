//
//  LandmarkDTOToModelBridge.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 19.04.26.
//

/// initialize Landmark from LandmarkDTO - connection point between Model layer and Presetnation layer

extension Landmark {
	static func create(from landmarkDTO: LandmarkDTO) -> Self {
		var events: [Landmark.HistoricalEvent]?
		for event in landmarkDTO.events {
			var landmarkEvent: HistoricalEvent? = nil
			if event.event == "Creation start" {
				landmarkEvent = HistoricalEvent(eventType: .constructionStarted, eventStart: event.event_begin, eventEnd: event.event_end)
			}
			else if event.event == "Creation completed" {
				landmarkEvent = HistoricalEvent(eventType: .constructionCompleted, eventStart: event.event_begin, eventEnd: event.event_end)
			}

			if let landmarkEvent {
				if events == nil {
					events = []
				}

				events?.append(landmarkEvent)
			}
		}

		// the landmark's own page language goes first and wins over a synonym with the same language code
		var localizedNames = [landmarkDTO.page_language: LocalizedName(name: landmarkDTO.artefacts_name, webReference: landmarkDTO.web_reference_wiki)]
		for synonym in landmarkDTO.synonyms ?? [] where localizedNames[synonym.lang] == nil {
			localizedNames[synonym.lang] = LocalizedName(name: synonym.lang_name, webReference: synonym.web_reference_wiki)
		}

		let landmark = Landmark(location: landmarkDTO.artefactsLocation.location, id: landmarkDTO.id, imageURL: landmarkDTO.artefactsImage?.path_to_image, events: events, styleIndexes: landmarkDTO.categories, localizedNames: localizedNames, primaryLanguage: landmarkDTO.page_language)

		return landmark
	}
}
