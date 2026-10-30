//
//  DeviceCornerRadius.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 28.03.26.
//

import SwiftUI

/// Clips the content to a shape that is concentric with the device display corners.
/// Apply it before any outer padding so the radius is reduced by that inset.
struct DeviceCornerRadius: ViewModifier {

	func body(content: Content) -> some View {
		content
			.clipShape(ConcentricRectangle(corners: .concentric(minimum: 12), isUniform: true))
	}
}

extension View {
	func deviceCornerRadius() -> some View {
		modifier(DeviceCornerRadius())
	}
}
