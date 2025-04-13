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
		.task {
			// guard markers.isEmpty else { return }
			await viewModel.requestArtifacts()
		}
		.onMapCameraChange { context in
			viewModel.visibleRegion = context.region // called many times, why? is this why it's slow?

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

