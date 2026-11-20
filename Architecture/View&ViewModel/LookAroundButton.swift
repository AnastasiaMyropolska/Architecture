//
//  LookAroundButton.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.11.26.
//

import SwiftUI
import MapKit // for `lookAroundViewer`

/// Round glass button that opens Look Around for a landmark; same size as `DismissButton`.
/// Shows nothing where Look Around is not available. The owner loads the scene (`LookAroundViewModel.loadScene()`).
struct LookAroundButton: View {
	@Bindable var viewModel: LookAroundViewModel

	var body: some View {
		Group {
			if viewModel.isAvailable {
				Button(action: viewModel.present) {
					Image(systemName: "binoculars.fill")
						.font(.headline.weight(.medium))
						.padding(6)
				}
				.buttonStyle(.glass)
				.buttonBorderShape(.circle)
				.controlSize(.regular)
				.accessibilityLabel("Look Around")
			}
		}
		.lookAroundViewer(isPresented: $viewModel.isPresented, initialScene: viewModel.scene)
	}
}
