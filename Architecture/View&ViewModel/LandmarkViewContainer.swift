//
//  LandmarkViewContainer.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.03.26.
//

import SwiftUI

struct LandmarkViewContainer: View {
	/// Only handed on to `LandmarkView`
	private let viewModel: LandmarkViewModel

	private let baseOffset: CGFloat = 0

	let onDismiss: () -> Void

	@State private var dragOffset: CGFloat = 0

	@State private var shouldDismiss = false

	init(viewModel: LandmarkViewModel, onDismiss: @escaping () -> Void) {
		self.viewModel = viewModel
		self.onDismiss = onDismiss
	}

	var body: some View {
		LandmarkView(viewModel: viewModel, onDismiss: { shouldDismiss = true })
		.overlay(alignment: .top) {
			DragIndicator()
		}
		.frame(height: 510)
		.frame(maxWidth: .infinity)
		.background(.ultraThinMaterial)
		.deviceCornerRadius()
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
				.font(.headline.weight(.medium))
				// between the regular and large control sizes, which are the only built-in steps
				.padding(6)
		}
		.buttonStyle(.glass)
		.buttonBorderShape(.circle)
		.controlSize(.regular)
	}
}

/// Loads the first landmark from the bundled JSON and shows the overlay for it
private struct LandmarkViewContainerPreview: View {
	@State private var viewModel: LandmarkViewModel?

	var body: some View {
		Group {
			if let viewModel {
				LandmarkViewContainer(viewModel: viewModel, onDismiss: {})
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
			viewModel = LandmarkViewModel(landmark: first)
		}
	}
}

#Preview {
	LandmarkViewContainerPreview()
}
