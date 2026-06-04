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
		VStack(alignment: .leading, spacing: 10) {
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
						// todo: don't show any image here
						Image(systemName: "photo")
							.font(.largeTitle)
							.foregroundStyle(.gray)
							.frame(maxWidth: .infinity)
							.frame(height: 200)
							.background(Color.gray.opacity(0.2))
							.cornerRadius(12)
					@unknown default:
						EmptyView()
					}
				}
			}

			Link("Learn more on Wiki", destination: viewModel.sourceURL)
			Text("asdf")

			Spacer()
		}
		.padding()
		.frame(maxWidth: .infinity, minHeight: 200)
	}
}


