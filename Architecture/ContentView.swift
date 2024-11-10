//
//  ContentView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 15.06.24.
//

import SwiftUI
import MapKit

struct ContentView: View {

	@State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
	@State private var visibleRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.1967608, longitude: 11.4132661), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)) // has to be @State, otherwise not possible to change in onMapCameraChange
	// position.followsUserLocation = true

	@State private var markers: [MKMapItem] = []
	@State private var selectedResult: MKMapItem?

	@State private var route: MKRoute?

	var body: some View {
		Map(position: $position, selection: $selectedResult) {
			ForEach (markers, id: \.self) { marker in
				Marker(item: marker)
			}

			UserAnnotation()
		}
		.task {
			// guard markers.isEmpty else { return }

			do {
				let request = Request(region: visibleRegion)

				markers = try await Parser(request: request).parse().map {
					$0.convertToMapItem()
				}
			} catch {

			}
		}
		.onMapCameraChange { context in
			visibleRegion = context.region

			Task {
				do {
					let request = Request(region: visibleRegion)
					markers = try await Parser(request: request).parse().map {
						$0.convertToMapItem()
					}
				} catch {

				}
			}
		}
		.onChange(of: selectedResult) {
			getDirection()
		}
		.safeAreaInset(edge: .bottom) {
			if let selectedResult {
				ItemInfoView(selectedResult: selectedResult, route: route)
					.frame(height: 128)
					.clipShape(RoundedRectangle(cornerRadius: 10))
					.padding([.top, .horizontal])
			}
		}
		.mapControls {
			MapUserLocationButton()
			MapCompass()
			MapScaleView()
		}
	}

	func getDirection() {
		route = nil
		guard let selectedResult else { return }

		let request = MKDirections.Request()
		request.source = MKMapItem.forCurrentLocation()
		request.destination = selectedResult

		Task {
			let directions = MKDirections(request: request)
			let responce = try? await directions.calculate()
			route = responce?.routes.first
		}
	}
}

