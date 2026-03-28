import Foundation
import CoreLocation

@MainActor
@Observable final class ContentViewModel {

    let locationManager: LocationManager = LocationManager()

	var isLocationServicesEnabled: Bool {
		locationManager.isAuthorized
    }
}
