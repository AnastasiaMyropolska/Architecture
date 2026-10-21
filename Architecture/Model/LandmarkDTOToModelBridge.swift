//
//  LandmarkDTOToModelBridge.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 19.04.26.
//

/// initialize Landmark from LandmarkDTO - connection point between Model layer and Presetnation layer

extension Landmark {
	static func create(from landmarkDTO: LandmarkDTO) -> Self {
		let title = landmarkDTO.artefacts_name

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

		let landmark = Landmark(location: landmarkDTO.artefactsLocation.location, id: landmarkDTO.id, title: title, URL: landmarkDTO.web_reference_wiki, imageURL: landmarkDTO.artefactsImage?.path_to_image, events: events, styleIndexes: landmarkDTO.categories)
		return landmark
	}
}
