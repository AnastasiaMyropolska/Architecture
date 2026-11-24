//
//  MapView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 15.06.24.
//

import SwiftUI
import MapKit // usually it's not a good idea to import a model framework into a view, but this view represenst a map, so exception is done here

struct MapView: View {

	@State private var viewModel = MapViewModel()

	@State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
	
	@State private var showSheet = false
	
	@State private var mapFrame: CGRect = .zero
	@State private var mapContext: MapCameraUpdateContext?
	// True from the first location fix until the initial request is made on the next camera event
	@State private var isWaitingForInitialRequest = false

	var body: some View {
		Map(position: $cameraPosition, selection: $viewModel.selectedLandmark) {
			ForEach(viewModel.visibleLandmarks) { landmark in
				Marker(
					landmark.localizedName ?? "",
					coordinate: landmark.location
				)
				.tag(landmark)
			}

			UserAnnotation() // user's location
		}
		.onMapCameraChange(frequency: .onEnd) { context in
			// Request landmarks only on the initial load (the first camera event after the user's location is known)
			// and when the user moved the map.
			// MapKit also reports camera-end events when the camera has not moved (e.g. while following the user's location),
			// reacting to those would start an endless request loop
			if isWaitingForInitialRequest {
				isWaitingForInitialRequest = false
				viewModel.requestArtifacts(for: context.region)
			} else if cameraPosition.positionedByUser {
				viewModel.requestArtifacts(for: context.region)
			}
			mapContext = context
		}
		.task {
			isWaitingForInitialRequest = await viewModel.waitForFirstLocationFix()
		}
		.onChange(of: viewModel.selectedLandmark) { _, newValue in
			showSheet = newValue != nil
			
			if let selectedMarker = newValue, let context = mapContext {
				adjustCameraIfNeeded(for: selectedMarker.mapItem(), context: context)
			}
		}
		.overlay(alignment: .bottom) {
			if showSheet, let landmarkViewModel = viewModel.landmarkViewModel {
				LandmarkViewContainer(viewModel: landmarkViewModel,
						   onDismiss: {
					viewModel.selectedLandmark = nil
				})
				// a new overlay per landmark, so view state never carries over to another one
				.id(landmarkViewModel.landmarkID)
				// Measure the 8pt bottom gap from the screen edge, not the home indicator
				.ignoresSafeArea(.container, edges: .bottom)
			}
		}
//		.animation(.spring, value: showSheet)
		.background(GeometryReader { proxy in
			Color.clear.onAppear { mapFrame = proxy.frame(in: .global) }
				.onChange(of: proxy.frame(in: .global)) { _, newFrame in
					mapFrame = newFrame
				}
		})
		.mapControls {
			MapUserLocationButton()
			// by default MapKit hides these when they aren't useful (compass while north is up, pitch toggle when zoomed out)
			MapPitchToggle() // 2D/3D
				.mapControlVisibility(.visible)
			MapCompass()
				.mapControlVisibility(.visible)
			//MapScaleView()
		}
	}
	
	// MARK: - Helper Methods
	
	private func adjustCameraIfNeeded(for selectedMarker: MKMapItem, context: MapCameraUpdateContext) {
		let overlayHeight: CGFloat = 400
		
		// Convert the marker's coordinate to screen position
		let markerCoordinate = selectedMarker.location.coordinate
		let markerScreenY = coordinateToScreenY(
			coordinate: markerCoordinate,
			mapRect: context.rect,
			mapFrame: mapFrame
		)
		
		// Check if marker is hidden by overlay (in bottom 400 points)
		let hiddenThreshold = mapFrame.height - overlayHeight
		
		if markerScreenY > hiddenThreshold {
			// Calculate how much to shift the map
			// Positive shiftNeeded means marker is too low on screen
			let shiftNeeded = markerScreenY - hiddenThreshold + 30 // +30 for padding

			// To move marker UP on screen, we need to move the map center DOWN (south)
			// In screen coordinates: moving content down makes markers appear higher
			let newCenter = shiftMapCenter(
				currentCenter: context.camera.centerCoordinate,
				mapRect: context.rect,
				mapFrame: mapFrame,
				yOffset: shiftNeeded  // Positive offset moves center south, marker appears north
			)
			
			// Animate camera to new position
			withAnimation(.easeOut(duration: 0.5)) {
				cameraPosition = .camera(
					MapCamera(
						centerCoordinate: newCenter,
						distance: context.camera.distance,
						heading: context.camera.heading,
						pitch: context.camera.pitch
					)
				)
			}
		}
	}
	
	private func coordinateToScreenY(coordinate: CLLocationCoordinate2D, mapRect: MKMapRect, mapFrame: CGRect) -> CGFloat {
		let mapPoint = MKMapPoint(coordinate)
		
		// Calculate relative vertical position in map rect (0...1)
		let relativeY = (mapPoint.y - mapRect.origin.y) / mapRect.size.height
		
		// Convert to screen coordinates
		let screenY = relativeY * mapFrame.height
		
		return screenY
	}
	
	private func shiftMapCenter(currentCenter: CLLocationCoordinate2D, mapRect: MKMapRect, mapFrame: CGRect, yOffset: CGFloat) -> CLLocationCoordinate2D {
		let currentCenterPoint = MKMapPoint(currentCenter)
		
		// Calculate how much to shift in map points
		let pointsPerScreenPoint = mapRect.size.height / mapFrame.height
		let mapPointOffset = yOffset * pointsPerScreenPoint
		
		// Create new map point
		let newMapPoint = MKMapPoint(x: currentCenterPoint.x, y: currentCenterPoint.y + mapPointOffset)
		
		return newMapPoint.coordinate
	}
}

