//
//  LandmarkInfoView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.03.26.
//

import SwiftUI

/// Hero image with the title on top of it, followed by style, architect, dates and the actions
struct LandmarkInfoView: View {
	let viewModel: LandmarkInfoViewModel

	var body: some View {
		VStack(spacing: 0) {
			ZStack(alignment: .bottomLeading) {
				hero
				LinearGradient(colors: [.clear, .black.opacity(0.75)], startPoint: .center, endPoint: .bottom)
				Text(viewModel.title)
					.font(.title2.bold())
					.foregroundStyle(.white)
					.padding()
			}
			.frame(height: 250)
			.clipped()

			VStack(alignment: .leading, spacing: 12) {
				if !viewModel.styles.isEmpty {
					InfoRow(icon: "building.columns", title: "Style", value: viewModel.styles.joined(separator: ", "))
				}
				if let authors = viewModel.authors {
					InfoRow(icon: "person", title: "Architect", value: authors)
				}
				if let dates = viewModel.dates {
					InfoRow(icon: "calendar", title: "Built", value: dates)
				}
				Spacer(minLength: 0)
				LandmarkActions(onDirections: viewModel.openDirections)
				WikiLink(url: viewModel.sourceURL)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding()
		}
	}

	private var hero: some View {
		Color.gray.opacity(0.2)
			.overlay {
				AsyncImage(url: viewModel.imageURL) { image in
					image.resizable().scaledToFill()
				} placeholder: {
					EmptyView()
				}
				.id(viewModel.landmarkID)
				// .clipped() doesn't clip hit testing, so a portrait image would swallow touches outside the overlay
				.allowsHitTesting(false)
			}
			.clipped()
	}
}

/// One labelled fact with a tinted icon
struct InfoRow: View {
	let icon: String
	let title: LocalizedStringKey
	let value: String

	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: icon)
				.font(.subheadline.weight(.semibold))
				.foregroundStyle(.tint)
				.frame(width: 32, height: 32)
				.background(.tint.opacity(0.15), in: RoundedRectangle(cornerRadius: 9))
			VStack(alignment: .leading, spacing: 0) {
				Text(title)
					.font(.caption)
					.foregroundStyle(.secondary)
				Text(value)
					.font(.subheadline.weight(.semibold))
			}
		}
	}
}

/// Directions button at the bottom of the card
struct LandmarkActions: View {
	let onDirections: () -> Void

	var body: some View {
		Button(action: onDirections) {
			Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
				.frame(maxWidth: .infinity)
		}
		.buttonStyle(.glassProminent)
		.controlSize(.large)
	}
}

/// Wraps chips onto several lines
struct FlowLayout: Layout {
	var spacing: CGFloat = 6

	func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
		arrange(in: proposal.width ?? .infinity, subviews: subviews).size
	}

	func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
		let result = arrange(in: bounds.width, subviews: subviews)
		for (subview, origin) in zip(subviews, result.origins) {
			subview.place(at: CGPoint(x: bounds.minX + origin.x, y: bounds.minY + origin.y), proposal: .unspecified)
		}
	}

	private func arrange(in width: CGFloat, subviews: Subviews) -> (origins: [CGPoint], size: CGSize) {
		var origins: [CGPoint] = []
		var x: CGFloat = 0
		var y: CGFloat = 0
		var rowHeight: CGFloat = 0
		var maxX: CGFloat = 0
		for subview in subviews {
			let size = subview.sizeThatFits(.unspecified)
			if x > 0, x + size.width > width {
				x = 0
				y += rowHeight + spacing
				rowHeight = 0
			}
			origins.append(CGPoint(x: x, y: y))
			x += size.width + spacing
			rowHeight = max(rowHeight, size.height)
			maxX = max(maxX, x - spacing)
		}
		return (origins, CGSize(width: maxX, height: y + rowHeight))
	}
}

struct StyleChips: View {
	let styles: [String]

	var body: some View {
		FlowLayout {
			ForEach(styles, id: \.self) { style in
				Text(style)
					.font(.caption.weight(.medium))
					.padding(.horizontal, 10)
					.padding(.vertical, 4)
					.background(.tint.opacity(0.15), in: Capsule())
			}
		}
	}
}

struct WikiLink: View {
	let url: URL?

	var body: some View {
		if let url {
			Link(destination: url) {
				Label("Learn more on Wiki", systemImage: "arrow.up.right.square")
					.font(.subheadline.weight(.medium))
			}
		}
	}
}
