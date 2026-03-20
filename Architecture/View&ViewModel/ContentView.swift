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

	@State private var showSheet = false

	@State private var dragOffset: CGFloat = 0
	@State private var sheetOffset: CGFloat = 0

	var body: some View {
		GeometryReader { geometry in
			Map(position: $cameraPosition, selection: $viewModel.selectedMarker) {
				ForEach (viewModel.visibleMarkers, id: \.self) { marker in
					Marker(item: marker)
				}

				UserAnnotation() // user's location
			}
			.onMapCameraChange(frequency: .onEnd) { context in
				viewModel.requestArtifacts(for: context.region)
			}
			.onChange(of: viewModel.selectedMarker) { _, newValue in
				showSheet = newValue != nil
			}
			.overlay(alignment: .bottom) {
				if showSheet, let selectedItem = viewModel.selectedMarker {
					MapOverlay(
						selectedItem: selectedItem,
						screenHeight: geometry.size.height,
						dragOffset: $dragOffset,
						onDismiss: {
							viewModel.selectedMarker = nil
						}
					)
				}
			}
			.animation(.spring, value: showSheet)
			.mapControls {
				MapUserLocationButton()
				MapCompass()
				MapScaleView()
			}
		}
	}
}

