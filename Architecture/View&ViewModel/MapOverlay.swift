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
	let screenHeight: CGFloat
	@Binding var dragOffset: CGFloat
	let baseOffset: CGFloat = 20

	let onDismiss: () -> Void

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
			HStack {
				// Drag indicator
				Capsule()
					.fill(.secondary.opacity(0.5))
					.frame(width: 40, height: 5)
					.padding(.top, 8)
					.padding(.bottom, 4)
				
				Button {
					withAnimation(.spring) {
						dragOffset = 0
						onDismiss()
					}
				} label: {
					Image(systemName: "xmark")
						.font(.system(size: 14, weight: .semibold))
						.foregroundStyle(.white)
						.frame(width: 28, height: 28)
						.background(.gray.opacity(0.6), in: Circle())
						.background(.ultraThinMaterial, in: Circle())
				}
			}

			ArtefactInfoView(selectedItem: selectedItem)
		}
		.frame(height: screenHeight / 2)
		.frame(maxWidth: .infinity)
		.background(.ultraThinMaterial)
		.clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
		.shadow(radius: 10)
		.padding(.horizontal)
//		.padding(.bottom, 10)
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
							dragOffset = 0
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
