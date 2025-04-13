//
//  ContentView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 15.06.24.
//

import SwiftUI
import MapKit

struct ContentView: View {

	var viewModel = ContentViewModel()

	//private var locationManager = LocationManager()
	@State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
	@State private var visibleRegion: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 48.1967608, longitude: 11.4132661), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)) // has to be @State, otherwise not possible to change in onMapCameraChange // TODO: wft is this, why hardcoded? we should use user's location
	// position.followsUserLocation = true

	@State private var markers: [MKMapItem] = []
	@State private var selectedResult: MKMapItem?

	@State private var route: MKRoute?

	var body: some View {
		Map(position: $cameraPosition, selection: $selectedResult) {
			ForEach (markers, id: \.self) { marker in
				Marker(item: marker)
			}

			UserAnnotation() // user's location
		}
		.task {
			// guard markers.isEmpty else { return }
			markers = await viewModel.requestArtifacts()
		}
		.onMapCameraChange { context in
			viewModel.visibleRegion = context.region // called many times, why?

			Task {
				markers = await viewModel.requestArtifacts()
			}
		}
//		.onChange(of: selectedResult) {
//			getDirection()
//		}
		.safeAreaInset(edge: .bottom) {
			if let selectedResult {
				ItemInfoView(selectedMarker: selectedResult, route: route)
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

//	func getDirection() {
//		route = nil
//		guard let selectedResult else { return }
//
//		let request = MKDirections.Request()
//		request.source = MKMapItem.forCurrentLocation()
//		request.destination = selectedResult
//
//		Task {
//			let directions = MKDirections(request: request)
//			let responce = try? await directions.calculate()
//			route = responce?.routes.first
//		}
//	}
}

