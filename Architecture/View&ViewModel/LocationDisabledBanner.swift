//
//  LocationDisabledBanner.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 28.03.26.
//

import SwiftUI

struct LocationDisabledBanner: View {
	var body: some View {
		VStack(spacing: 12) {
			HStack {
				Image(systemName: "location.slash")
					.font(.largeTitle)
				
				Text("Location Services Off")
					.font(.headline)
			}

			Button("Open Settings") {
				if let url = URL(string: UIApplication.openSettingsURLString) {
					UIApplication.shared.open(url)
				}
			}
		}
		.padding()
		.background(.ultraThinMaterial)
		.deviceCornerRadius()
	}
}
