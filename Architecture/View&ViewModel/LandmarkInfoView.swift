//
//  LandmarkInfoView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.03.26.
//

import SwiftUI

/// Hero image with the title on top of it, followed by style chips, dates and the source link
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
			.frame(height: 270)
			.clipped()

			VStack(alignment: .leading, spacing: 10) {
				StyleChips(styles: viewModel.styles)
				DateLines(started: viewModel.started, completed: viewModel.completed)
				Spacer(minLength: 0)
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
			}
			.clipped()
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

struct DateLines: View {
	let started: String?
	let completed: String?

	var body: some View {
		VStack(alignment: .leading, spacing: 4) {
			if let started {
				Label("Started \(started)", systemImage: "hammer")
			}
			if let completed {
				Label("Completed \(completed)", systemImage: "checkmark.seal")
			}
		}
		.font(.subheadline)
		.foregroundStyle(.secondary)
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
