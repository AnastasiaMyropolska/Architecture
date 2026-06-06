//
//  ArtefactToPOIBridge.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 19.04.26.
//

/// initialize POI from Artefact - connection point between Model layer and Presetnation layer

extension PointOfInterest {
	static func poi(from artefact: Artefact) -> Self {
		let title = artefact.artefacts_name

		var events: [PointOfInterest.HistoricalEvent]?
		for event in artefact.events {
			var poiEvent: HistoricalEvent? = nil
			if event.event == "Creation start" {
				poiEvent = HistoricalEvent(eventType: .constructionStarted, eventStart: event.event_begin, eventEnd: event.event_end)
			}
			else if event.event == "Creation completed" {
				poiEvent = HistoricalEvent(eventType: .constructionCompleted, eventStart: event.event_begin, eventEnd: event.event_end)
			}

			if let poiEvent {
				if events == nil {
					events = []
				}

				events?.append(poiEvent)
			}
		}

		let poi = PointOfInterest(location: artefact.artefactsLocation.location, id: artefact.id, title: title, URL: artefact.web_reference_wiki, imageURL: artefact.artefactsImage?.path_to_image, events: events, categories: artefact.categories)
		return poi
	}
}
