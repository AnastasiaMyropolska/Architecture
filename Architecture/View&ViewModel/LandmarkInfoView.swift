//
//  LandmarkInfoView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 20.03.26.
//

import SwiftUI

/// Hero image with the title on top of it, followed by style, architect, dates and the actions
struct LandmarkInfoView: View {
	let onDismiss: () -> Void

	/// Created once, not in `body`, so loaded state survives re-renders (`body` re-runs on every drag frame of the overlay).
	/// The presenter gives the overlay `.id(landmark.id)`, so selecting another landmark creates a new view and new view models
	@State private var viewModel: LandmarkInfoViewModel
	@State private var lookAroundViewModel: LookAroundViewModel

	init(landmark: Landmark, onDismiss: @escaping () -> Void) {
		self.onDismiss = onDismiss
		_viewModel = State(initialValue: LandmarkInfoViewModel(landmark: landmark))
		_lookAroundViewModel = State(initialValue: LookAroundViewModel(landmark: landmark))
	}

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
			.overlay(alignment: .topTrailing) {
				// pinned to the right: dismiss, with Look Around right below it where available
				VStack(spacing: 8) {
					DismissButton(action: onDismiss)
					LookAroundButton(viewModel: lookAroundViewModel)
				}
				.padding(14)
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
				if let description = viewModel.description {
					// scrolls when the intro is longer than the space left above the actions
					ScrollView {
						Text(description)
							.font(.subheadline)
							.frame(maxWidth: .infinity, alignment: .leading)
					}
				} else {
					Spacer(minLength: 0)
				}
				LandmarkActions(onDirections: viewModel.openDirections)
				WikiLink(url: viewModel.sourceURL)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding()
		}
		.task {
			await viewModel.loadDescription()
		}
		// loaded here, not in `LookAroundButton`: that view is empty until the scene is loaded, so a `.task` on it would never start
		.task {
			await lookAroundViewModel.loadScene()
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
					.lineLimit(2)
					// take the height needed for a second line instead of truncating to one
					.fixedSize(horizontal: false, vertical: true)
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
