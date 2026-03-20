//
//  ArtefactInfoView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.03.26.
//

import SwiftUI
import MapKit

struct ArtefactInfoView: View {
	let selectedItem: MKMapItem

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {


			
			Spacer()
		}
		.padding()
		.frame(maxWidth: .infinity, minHeight: 200)
	}
}

struct ArtefactHeaderView: View {
	let selectedItem: MKMapItem
	let onDismiss: () -> Void

	var body: some View {
		HStack {
			Spacer()

			Text(selectedItem.name ?? "Unknown Location")
				.font(.headline)

			Spacer()

			Button {
				withAnimation(.spring) {
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
			.padding(.trailing, 16)
			.padding(.top, 8)
		}
	}
}
