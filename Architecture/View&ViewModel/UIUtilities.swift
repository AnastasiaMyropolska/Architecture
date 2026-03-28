import SwiftUI
import UIKit

public enum UIUtilities {

	// AI solution, not sure if it's optimal
    public static func adaptiveCornerRadius(minimum: CGFloat = 38, fallbackBottomInset: CGFloat = 34) -> CGFloat {
        // Determine bottom safe area inset from the key window; fall back if unavailable
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .windows
            .first { $0.isKeyWindow }

        let bottomInset = keyWindow?.safeAreaInsets.bottom ?? fallbackBottomInset
        return max(bottomInset, minimum)
    }
}
