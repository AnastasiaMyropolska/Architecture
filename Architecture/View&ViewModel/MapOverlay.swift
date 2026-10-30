//
//  MapOverlay.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.03.26.
//

import SwiftUI

struct MapOverlay: View {
	let selectedItem: Landmark

	private let baseOffset: CGFloat = 0

	let onDismiss: () -> Void

	@State private var dragOffset: CGFloat = 0

	@State private var shouldDismiss = false

	var body: some View {
		LandmarkInfoView(viewModel: LandmarkInfoViewModel(landmark: selectedItem))
		.overlay(alignment: .top) {
			DragIndicator()
		}
		.frame(height: 400)
		.frame(maxWidth: .infinity)
		.background(.ultraThinMaterial)
		.deviceCornerRadius()
		.overlay(alignment: .topTrailing) {
			DismissButton { shouldDismiss = true }
		}
		.shadow(radius: 10)
		.padding(.horizontal, 8)
			.padding(.bottom, 8)
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
			.padding(.top, 20)
			.padding(.bottom, 4)
	}
}

struct DismissButton: View {
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			Image(systemName: "xmark")
				.font(.system(size: 14, weight: .semibold))
				.foregroundStyle(.white)
				.frame(width: 28, height: 28)
				.background(.gray.opacity(0.6), in: Circle())
				.background(.ultraThinMaterial, in: Circle())
		}
		.padding(14)
	}
}

/// Loads the first landmark from the bundled JSON and shows the overlay for it
private struct MapOverlayPreview: View {
	@State private var landmark: Landmark?

	var body: some View {
		Group {
			if let landmark {
				MapOverlay(selectedItem: landmark, onDismiss: {})
			} else {
				ProgressView()
			}
		}
		.task {
			guard let data = try? await ServerDataFetcher.fetchLocal(),
				  let (landmarkDTOs, categoryDTOs) = try? await DTODecoder.decode(data: data) else { return }
			guard var first = landmarkDTOs.first.map({ Landmark.create(from: $0) }) else { return }
			// MapViewModel resolves styles when a landmark is selected, so do the same here
			let styleIndexes = first.styleIndexes
			let styles = categoryDTOs.map { Style.create(from: $0) }
			first.styles = styles.filter { styleIndexes.contains($0.index) }
			landmark = first
		}
	}
}

#Preview {
	MapOverlayPreview()
}
