//
//  MapOverlay.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.03.26.
//

import SwiftUI

struct MapOverlay: View {
	let selectedItem: PointOfInterest // move to view model, remove MapKit

	let baseOffset: CGFloat = 20

	let onDismiss: () -> Void

	@State private var dragOffset: CGFloat = 0

	@State private var shouldDismiss = false

	var body: some View {
		VStack(spacing: 0) {
			DragIndicator()

			Spacer()
				.frame(height: 10)

			POIHeaderView(viewModel:POIInfoViewModel(poi: selectedItem), shouldDismiss: $shouldDismiss)

			POIInfoView(viewModel:POIInfoViewModel(poi: selectedItem))
		}
		.frame(height: 400)
		.frame(maxWidth: .infinity)
		.background(.ultraThinMaterial)
		.deviceCornerRadius()
		.shadow(radius: 10)
		.padding(.horizontal)
		.offset(y: dragOffset + baseOffset)
		.transition(.move(edge: .bottom).combined(with: .opacity))
		.onChange(of: shouldDismiss, { oldValue, newValue in
			if shouldDismiss {
				withAnimation(.spring) {
					onDismiss()
				}
			}
		})
		.gesture(
			DragGesture()
				.onChanged { value in
					// Only allow dragging downwards
					if value.translation.height > 0 {
						dragOffset = value.translation.height
					}
				}
				.onEnded { value in
					// Dismiss if dragged down more than 100 points
					if value.translation.height > 100 {
						shouldDismiss = true
					} else {
						// Snap back if not dragged enough
						withAnimation(.spring) {
							dragOffset = 0
						}
					}
				}
		)
	}
}

struct DragIndicator: View {
	var body: some View {
		Capsule()
			.fill(.secondary.opacity(0.5))
			.frame(width: 40, height: 5)
			.padding(.top, 8)
			.padding(.bottom, 4)
	}
}
