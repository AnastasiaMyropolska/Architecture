//
//  ContentView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 15.06.24.
//

import SwiftUI
import MapKit

struct ContentView: View {

	@State private var viewModel = ContentViewModel()

	@State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)

	@State private var route: MKRoute?

	@State private var selectedResult: MKMapItem? // move to viewModel

	var body: some View {
		Map(position: $cameraPosition, selection: $selectedResult) {
			ForEach (viewModel.visibleMarkers, id: \.self) { marker in
				Marker(item: marker)
			}

			UserAnnotation() // user's location
		}
		.onMapCameraChange(frequency: .onEnd) { context in
			viewModel.visibleRegion = context.region

			Task {
				await viewModel.requestArtifacts()
			}
		}
//		.onChange(of: selectedResult) {
//			getDirection()
//		}
		.safeAreaInset(edge: .bottom) {
			if let selectedMarker = viewModel.selectedMarker {
				ItemInfoView(selectedMarker: selectedMarker, route: route)
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

