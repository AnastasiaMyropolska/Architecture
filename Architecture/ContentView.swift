//
//  ContentView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 15.06.24.
//

import SwiftUI
import MapKit

struct ContentView: View {

	@State private var position: MapCameraPosition = .automatic
	@State private var markers: [MKMapItem] = []

	var body: some View {
		Map(position: $position) {
			ForEach (markers, id: \.self) { marker in
				Marker(item: marker)
			}
		}.onAppear() {
		}
		.task {
			guard markers.isEmpty else { return }

			do {
				markers = try await Parser().parse().map {
					$0.convertToMapItem()
				}
			} catch {

			}
		}
	}
}
