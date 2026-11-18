//
//  LandmarkFilterView.swift
//  Architecture
//
//  Filter screen: three expandable rows (architect, century, style) with multiple selection.
//

import SwiftUI
import MapKit

// MARK: - Filter state & sample data

/// Everything the user has picked. Values inside one category are OR-ed, categories are AND-ed.
struct LandmarkFilter: Equatable {
	var architects: Set<String> = []
	var centuries: Set<Int> = []
	var styles: Set<String> = []

	var activeCount: Int { architects.count + centuries.count + styles.count }
	var isEmpty: Bool { activeCount == 0 }

	mutating func reset() { self = LandmarkFilter() }
}

/// Placeholder options for previews; the real lists will come from the loaded landmarks.
enum FilterOptions {
	static let architects = [
		"Adam, Philip", "Adelung, Friedrich", "Alberti, Leon Battista", "Bernini, Gian Lorenzo",
		"Borromini, Francesco", "Brunelleschi, Filippo", "Bramante, Donato", "Cuvilliés, François de",
		"Eiffel, Gustave", "Fischer von Erlach, Johann Bernhard", "Gaudí, Antoni", "Gropius, Walter",
		"Hildebrandt, Johann Lukas von", "Horta, Victor", "Jones, Inigo", "Klenze, Leo von",
		"Le Corbusier", "Mansart, François", "Michelangelo", "Neumann, Balthasar",
		"Palladio, Andrea", "Pöppelmann, Matthäus Daniel", "Schinkel, Karl Friedrich", "Semper, Gottfried",
		"Sinan, Mimar", "Vanbrugh, John", "Vignola, Giacomo Barozzi da", "Wren, Christopher",
		"Zimmermann, Dominikus", "Zumthor, Peter"
	]

	/// 3rd … 20th century, at most 20 entries
	static let centuries = Array(3...20)

	static let styles = [
		"Ancient", "Byzantine", "Romanesque", "Gothic", "Renaissance", "Mannerism",
		"Baroque", "Rococo", "Neoclassical", "Gothic Revival", "Historicism", "Art Nouveau",
		"Art Deco", "Modernist", "Bauhaus", "Brutalist", "Postmodern", "Deconstructivist"
	]

	struct SampleLandmark {
		let architect: String
		let century: Int
		let style: String
	}

	/// Deterministic pseudo-random landmarks so the "Show N Landmarks" count reacts to the selection.
	static let sampleLandmarks: [SampleLandmark] = {
		var seed: UInt64 = 42
		func next() -> Int {
			seed = seed &* 6364136223846793005 &+ 1442695040888963407
			return Int(seed >> 33)
		}
		return (0..<6000).map { _ in
			SampleLandmark(
				architect: architects[next() % architects.count],
				century: centuries[next() % centuries.count],
				style: styles[next() % styles.count]
			)
		}
	}()

	static func count(matching filter: LandmarkFilter) -> Int {
		sampleLandmarks.filter { landmark in
			(filter.architects.isEmpty || filter.architects.contains(landmark.architect))
				&& (filter.centuries.isEmpty || filter.centuries.contains(landmark.century))
				&& (filter.styles.isEmpty || filter.styles.contains(landmark.style))
		}.count
	}
}

extension Int {
	private static let ordinalFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .ordinal
		return formatter
	}()

	/// "3rd", "11th", … (localized)
	var ordinalText: String {
		Self.ordinalFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
	}
}

private func flip<T: Hashable>(_ set: inout Set<T>, _ value: T) {
	if !set.insert(value).inserted { set.remove(value) }
}

/// "Any" / the item / "A, B" / "3 selected"
private func summary(of items: [String]) -> String? {
	switch items.count {
	case 0: return nil
	case 1, 2: return items.joined(separator: ", ")
	default: return "\(items.count) selected"
	}
}

// MARK: - Chips

/// Outlined pill with a clear background and a thin border; the selected state gets a thicker, darker border and a faint fill.
/// Keeps a 44pt minimum touch target.
struct FilterChip: View {
	let title: String
	var showsRemoveIcon = false
	let isSelected: Bool
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			HStack(spacing: 6) {
				Text(title).lineLimit(1)
				if showsRemoveIcon {
					Image(systemName: "xmark").font(.caption.bold())
				}
			}
			.font(.body)
			.foregroundStyle(.primary)
			.padding(.horizontal, 16)
			.frame(minHeight: 44)
			.background(isSelected ? Color(.secondarySystemFill) : Color.clear, in: Capsule())
			.overlay(
				Capsule().strokeBorder(
					isSelected ? Color.primary : Color(.separator),
					lineWidth: isSelected ? 2 : 1
				)
			)
			.contentShape(Capsule())
		}
		.buttonStyle(.plain)
		.accessibilityAddTraits(isSelected ? .isSelected : [])
	}
}

/// Multi-select chips in a wrapping layout. With `collapsedCount` set, only that many chips show until "Show all";
/// selected chips are never hidden.
private struct ChipGroup<T: Hashable>: View {
	let options: [T]
	let title: (T) -> String
	@Binding var selection: Set<T>
	var collapsedCount: Int?
	@State private var showsAll = false

	var body: some View {
		let visible = visibleOptions
		FlowLayout(spacing: 8) {
			ForEach(visible, id: \.self) { value in
				FilterChip(title: title(value), isSelected: selection.contains(value)) {
					flip(&selection, value)
				}
			}
			if let collapsedCount, options.count > collapsedCount {
				Button(showsAll ? "Show less" : "Show all \(options.count)") {
					withAnimation(.snappy) { showsAll.toggle() }
				}
				.buttonStyle(.plain)
				.fontWeight(.semibold)
				.underline()
				.padding(.horizontal, 8)
				.frame(minHeight: 44)
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private var visibleOptions: [T] {
		guard let collapsedCount, !showsAll else { return options }
		return options.enumerated()
			.filter { $0.offset < collapsedCount || selection.contains($0.element) }
			.map(\.element)
	}
}

// MARK: - Architect picker

/// Search field, removable tokens for the selection, and a scrollable multi-select list showing at most `maxVisibleRows` rows.
private struct ArchitectPicker: View {
	@Binding var selection: Set<String>
	@Binding var query: String
	/// rows visible at once; longer lists scroll
	var maxVisibleRows = 15

	private let rowHeight: CGFloat = 44

	private var matches: [String] {
		query.isEmpty
			? FilterOptions.architects
			: FilterOptions.architects.filter { $0.localizedCaseInsensitiveContains(query) }
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			searchField
			if !selection.isEmpty { tokens }
			list
		}
	}

	private var searchField: some View {
		HStack {
			Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
			TextField("Search architects", text: $query)
				.textInputAutocapitalization(.words)
				.autocorrectionDisabled()
			if !query.isEmpty {
				Button { query = "" } label: {
					Image(systemName: "xmark.circle.fill")
						.foregroundStyle(.secondary)
						.frame(width: 32, height: 44)
				}
				.buttonStyle(.plain)
				.accessibilityLabel("Clear search")
			}
		}
		.padding(.horizontal, 12)
		.frame(minHeight: 44)
		.background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: 12))
	}

	private var tokens: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 8) {
				ForEach(selection.sorted(), id: \.self) { architect in
					FilterChip(title: architect, showsRemoveIcon: true, isSelected: true) {
						selection.remove(architect)
					}
					.accessibilityLabel("Remove \(architect)")
				}
				Button("Clear all") { selection.removeAll() }
					.buttonStyle(.plain)
					.fontWeight(.semibold)
					.underline()
					.padding(.horizontal, 8)
					.frame(minHeight: 44)
			}
		}
	}

	private var list: some View {
		let rows = matches
		return ScrollView {
			LazyVStack(spacing: 0) {
				ForEach(rows, id: \.self) { architect in
					Button {
						flip(&selection, architect)
					} label: {
						HStack(spacing: 12) {
							Text(architect)
								.foregroundStyle(.primary)
								.lineLimit(1)
							Spacer()
							if selection.contains(architect) {
								Image(systemName: "checkmark")
									.font(.body.weight(.semibold))
									.foregroundStyle(.primary)
							}
						}
						// same inset as the text inside a chip, so names line up with chip labels
						.padding(.horizontal, 16)
						.frame(height: rowHeight)
						.contentShape(Rectangle())
					}
					.buttonStyle(.plain)
					.accessibilityAddTraits(selection.contains(architect) ? .isSelected : [])
				}
				if rows.isEmpty {
					Text("No architects found")
						.foregroundStyle(.secondary)
						.frame(maxWidth: .infinity)
						.frame(height: rowHeight)
				}
			}
		}
		.frame(height: rowHeight * CGFloat(max(1, min(rows.count, maxVisibleRows))))
	}
}

// MARK: - Filter screen

/// All categories sit in one scroll view under section titles (style, century, architect),
/// with a "Clear all" + "Show N Landmarks" bar at the bottom. The architect list starts collapsed.
struct LandmarkFilterView: View {
	@Binding var filter: LandmarkFilter
	@State private var architectQuery = ""
	@State private var architectsExpanded: Bool
	@Environment(\.dismiss) private var dismiss

	init(filter: Binding<LandmarkFilter>, architectsExpanded: Bool = false) {
		_filter = filter
		_architectsExpanded = State(initialValue: architectsExpanded)
	}

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 0) {
					section("Style", value: summary(of: filter.styles.sorted())) {
						ChipGroup(options: FilterOptions.styles, title: { $0 }, selection: $filter.styles, collapsedCount: 8)
					}
					Divider().padding(.vertical, 24)
					section("Century", value: summary(of: filter.centuries.sorted().map(\.ordinalText))) {
						ChipGroup(options: FilterOptions.centuries, title: { $0.ordinalText }, selection: $filter.centuries)
					}
					Divider().padding(.vertical, 24)
					section("Architect", value: summary(of: filter.architects.sorted()), isExpanded: $architectsExpanded) {
						ArchitectPicker(selection: $filter.architects, query: $architectQuery, maxVisibleRows: 10)
					}
				}
				.padding(.horizontal)
				.padding(.vertical, 20)
			}
			.scrollDismissesKeyboard(.interactively)
			.navigationTitle("Filters")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Close", systemImage: "xmark") { dismiss() }
				}
			}
			.safeAreaInset(edge: .bottom) { bottomBar }
		}
		.presentationBackground(.ultraThinMaterial)
	}

	/// With `isExpanded` the title row becomes a button with a chevron that shows or hides the content.
	private func section<Content: View>(
		_ title: String,
		value: String?,
		isExpanded: Binding<Bool>? = nil,
		@ViewBuilder content: () -> Content
	) -> some View {
		let showsContent = isExpanded?.wrappedValue ?? true
		return VStack(alignment: .leading, spacing: 16) {
			let titleRow = HStack(alignment: .firstTextBaseline, spacing: 8) {
				Text(title).font(.title3.bold())
				Spacer(minLength: 8)
				if let value {
					Text(value).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
				}
				if let isExpanded {
					Image(systemName: "chevron.down")
						.font(.footnote.bold())
						.foregroundStyle(.secondary)
						.rotationEffect(.degrees(isExpanded.wrappedValue ? 180 : 0))
				}
			}
			if let isExpanded {
				Button {
					withAnimation(.snappy) { isExpanded.wrappedValue.toggle() }
				} label: {
					titleRow
						.frame(minHeight: 44)
						.contentShape(Rectangle())
				}
				.buttonStyle(.plain)
				.accessibilityAddTraits(.isHeader)
				.accessibilityHint(isExpanded.wrappedValue ? "Collapses the options" : "Expands the options")
			} else {
				titleRow.accessibilityAddTraits(.isHeader)
			}
			if showsContent {
				content()
			}
		}
	}

	private var bottomBar: some View {
		let count = FilterOptions.count(matching: filter)
		return VStack(spacing: 0) {
			Divider()
			HStack {
				Button("Clear all") { filter.reset() }
					.buttonStyle(.plain)
					.fontWeight(.semibold)
					.underline()
					.frame(minHeight: 44)
					.disabled(filter.isEmpty)
					.opacity(filter.isEmpty ? 0.4 : 1)
				Spacer()
				Button {
					dismiss()
				} label: {
					Text(count == 0 ? "No Landmarks Found" : "Show \(count) Landmark\(count == 1 ? "" : "s")")
						.padding(.horizontal, 12)
				}
				.buttonStyle(.glass)
				.controlSize(.large)
				.disabled(count == 0)
			}
			.padding(.horizontal)
			.padding(.vertical, 8)
		}
		.background(.bar)
	}
}

// MARK: - Previews

private struct FilterPreviewHost: View {
	@State private var filter: LandmarkFilter
	let architectsExpanded: Bool

	init(initial: LandmarkFilter = LandmarkFilter(), architectsExpanded: Bool = false) {
		_filter = State(initialValue: initial)
		self.architectsExpanded = architectsExpanded
	}

	var body: some View { LandmarkFilterView(filter: $filter, architectsExpanded: architectsExpanded) }
}

private let sampleSelection = LandmarkFilter(
	architects: ["Adelung, Friedrich", "Adam, Philip", "Bernini, Gian Lorenzo"],
	centuries: [17, 18],
	styles: ["Baroque", "Rococo"]
)

#Preview("Nothing selected") {
	FilterPreviewHost()
}

#Preview("Selected") {
	FilterPreviewHost(initial: sampleSelection)
}

#Preview("Architects expanded") {
	FilterPreviewHost(initial: sampleSelection, architectsExpanded: true)
}

/// Material needs something to blur, so present the screen as a sheet over a map.
private struct FilterOverMapPreviewHost: View {
	@State private var filter = sampleSelection
	@State private var isPresented = true

	var body: some View {
		Map()
			.sheet(isPresented: $isPresented) {
				LandmarkFilterView(filter: $filter)
					.presentationDetents([.large])
			}
	}
}

#Preview("Over map") {
	FilterOverMapPreviewHost()
}
