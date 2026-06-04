//
//  POIHeaderView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 04.06.26.
//

import SwiftUI

struct POIHeaderView: View {
	let viewModel: POIInfoViewModel
	@Binding var shouldDismiss: Bool

	var body: some View {
		HStack {
			Spacer()
				.frame(width: 20)

			VStack(alignment: .leading) {
				Text(viewModel.title)
					.font(.headline)
				Text(viewModel.category)
					.font(.subheadline)
			}

			Spacer()

			Button {
				shouldDismiss = true
			} label: {
				Image(systemName: "xmark")
					.font(.system(size: 14, weight: .semibold))
					.foregroundStyle(.white)
					.frame(width: 28, height: 28)
					.background(.gray.opacity(0.6), in: Circle())
					.background(.ultraThinMaterial, in: Circle())
			}
			.padding(.trailing, 16)
			.padding(.top, -20)
		}
	}
}
