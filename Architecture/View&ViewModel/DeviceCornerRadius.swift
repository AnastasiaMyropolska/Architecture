//
//  DeviceCornerRadius.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 28.03.26.
//

import SwiftUI

struct DeviceCornerRadius: ViewModifier {

	private var deviceCornerRadius: CGFloat {
		// Determine bottom safe area inset from the key window; fall back if unavailable
		let keyWindow = UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.first?
			.windows
			.first { $0.isKeyWindow }

		let bottomInset = keyWindow?.safeAreaInsets.bottom ?? 34
		return max(bottomInset, 38)
	}

	func body(content: Content) -> some View {
		content
			.cornerRadius(deviceCornerRadius)
	}
}

extension View {
	func deviceCornerRadius() -> some View {
		modifier(DeviceCornerRadius())
	}
}
