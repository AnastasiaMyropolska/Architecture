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
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			Text(selectedItem.name ?? "Unknown Location")
				.font(.headline)
			
			
			Spacer()
		}
		.padding()
		.frame(maxWidth: .infinity, minHeight: 200)
	}
}
