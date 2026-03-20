//
//  MapOverlay.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.03.26.
//

import SwiftUI
import MapKit

struct MapOverlay: View {
	let selectedItem: MKMapItem

	let baseOffset: CGFloat = 20

	let onDismiss: () -> Void
	

	@State private var dragOffset: CGFloat = 0

	private var cornerRadius: CGFloat {
		// Default fallback if safeAreaInsets are zero
		let keyWindow = UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.first?.windows.first { $0.isKeyWindow }

		let bottomInset = keyWindow?.safeAreaInsets.bottom ?? 34
		return max(bottomInset, 38) // Ensure minimum radius for smooth look
	}

	var body: some View {
		VStack(spacing: 0) {
			DragIndicator()

			ArtefactHeaderView(selectedItem: selectedItem, onDismiss: onDismiss)

			ArtefactInfoView(selectedItem: selectedItem)
		}
		.frame(height: 400)
		.frame(maxWidth: .infinity)
		.background(.ultraThinMaterial)
		.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
		.shadow(radius: 10)
		.padding(.horizontal)
		.offset(y: dragOffset + baseOffset)
		.transition(.move(edge: .bottom).combined(with: .opacity))
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
						withAnimation(.spring) {
							onDismiss()
						}
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
