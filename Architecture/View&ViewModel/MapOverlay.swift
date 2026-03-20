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
	@Binding var showSheet: Bool
	@Binding var dragOffset: CGFloat
	
	let onDismiss: () -> Void
	
	var body: some View {
		VStack(spacing: 0) {
			// Drag indicator
			Capsule()
				.fill(.secondary.opacity(0.5))
				.frame(width: 40, height: 5)
				.padding(.top, 8)
				.padding(.bottom, 4)
			
			ArtefactInfoView(selectedItem: selectedItem)
		}
		.frame(height: screenHeight / 2)
		.frame(maxWidth: .infinity)
		.background(.ultraThinMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 40))
		.shadow(radius: 10)
		.padding(.horizontal)
		.padding(.bottom, 10)
		.offset(y: dragOffset)
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
							showSheet = false
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
