//
//  ArtefactToPOIBridge.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 19.04.26.
//

/// initialize POI from Artefact - connection point between Model layer and Presetnation layer

extension PointOfInterest {
	static func poi(from artefact: Artefact) -> Self {
		let title = artefact.artefacts_name // or if .empty ?? "Unknown"

		var poiEvent: PointOfInterest.HistoricalEvent? = nil
		for event in artefact.events {
			if event.event == "Creation start" {
				poiEvent = HistoricalEvent(eventType: .construction, eventStart: event.event_begin, eventEnd: event.event_end)
			}
		}
		let events = poiEvent != nil ? [poiEvent] : nil

		let poi = PointOfInterest(location: artefact.artefactsLocation.location, title: title, URL: artefact.web_reference_wiki, imageURL: artefact.artefactsImage?.path_to_image, events: poiEvent)
		return poi
	}
}
