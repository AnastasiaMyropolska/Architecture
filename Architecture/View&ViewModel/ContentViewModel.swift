//
//  ContentViewModel.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 28.03.26.
//

import Foundation
import CoreLocation

@MainActor
@Observable final class ContentViewModel {

	@ObservationIgnored let locationManager: LocationManager = LocationManager()

	var isLocationServicesEnabled: Bool {
		locationManager.isAuthorized
	}
}
