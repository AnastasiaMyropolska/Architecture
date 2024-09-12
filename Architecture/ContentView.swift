//
//  ContentView.swift
//  Maps
//
//  Created by Anastasia Myropolska on 15.06.24.
//

import SwiftUI
import MapKit

struct ContentView: View {

	//@StateObject var manager = LocationManager()
	@State private var searchResult: [MKMapItem] = []

	var body: some View {
		Map {
			ForEach (searchResult, id: \.self) { result in
				Marker(item: result)
			}
		}
		.onAppear {
			let region = MKCoordinateRegion(center: PointOfInterest.hofbrauhaus, span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
			//Searcher(searchResults: $searchResult).fetchPointsOfInterests(inRegion: region)
			Parser().parse()
		}
	}
}

struct Searcher {
	@Binding var searchResults: [MKMapItem]

	func fetchPointsOfInterests(inRegion: MKCoordinateRegion) {
		let placemark1 = MKPlacemark(coordinate: PointOfInterest.hofbrauhaus)
		let mapItem1 = MKMapItem(placemark: placemark1)
		mapItem1.name = "Hofbräuhaus"

		let placemark2 = MKPlacemark(coordinate: PointOfInterest.langwiederSee)
		let mapItem2 = MKMapItem(placemark: placemark2)
		mapItem2.name = "Langwieder See"

		searchResults = [mapItem1, mapItem2]
	}
}

enum PointOfInterest {
	static let hofbrauhaus = CLLocationCoordinate2D(latitude: 48.1376373, longitude: 11.5771745)
	static let langwiederSee = CLLocationCoordinate2D(latitude: 48.1967608, longitude: 11.4132661)
}
