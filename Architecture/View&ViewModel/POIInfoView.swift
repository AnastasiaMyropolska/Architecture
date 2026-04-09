//
//  POIInfoView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.03.26.
//

import SwiftUI

struct POIInfoView: View {
	let viewModel: POIInfoViewModel

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			if let imageURL = viewModel.imageURL {
				AsyncImage(url: imageURL) { phase in
					switch phase {
					case .empty:
						ProgressView()
							.frame(maxWidth: .infinity)
							.frame(height: 200)
							.background(Color.gray.opacity(0.2))
					case .success(let image):
						image
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(maxWidth: .infinity)
							.frame(height: 200)
					case .failure:
						Image(systemName: "photo")
							.font(.largeTitle)
							.foregroundStyle(.gray)
							.frame(maxWidth: .infinity)
							.frame(height: 200)
							.background(Color.gray.opacity(0.2))
					@unknown default:
						EmptyView()
					}
				}
				.cornerRadius(12)
			}
			
			Spacer()
		}
		.padding()
		.frame(maxWidth: .infinity, minHeight: 200)
	}
}

struct POIHeaderView: View {
	let viewModel: POIInfoViewModel
	@Binding var shouldDismiss: Bool

	var body: some View {
		HStack {
			Spacer()
				.frame(width: 20)

			Text(viewModel.title)
				.font(.headline)

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
			.padding(.top, 8)
		}
	}
}
