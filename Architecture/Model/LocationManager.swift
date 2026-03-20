//
//  LocationManager.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 28.07.24.
//

import SwiftUI
import CoreLocation

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
	
	/*@ObservationIgnored*/ let manager = CLLocationManager()
	var userLocation: CLLocation?
	var isAuthorized = false

	override init() {
		super.init()
		manager.delegate = self
		startLocationServices()
	}

	func startLocationServices() {
		if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
			manager.startUpdatingLocation()
			isAuthorized = true
		} else {
			isAuthorized = false
			manager.requestWhenInUseAuthorization()
		}
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		userLocation = locations.last
	}

	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		switch manager.authorizationStatus {
		case .authorizedAlways, .authorizedWhenInUse:
			isAuthorized = true
			manager.requestLocation()
		case .notDetermined:
			isAuthorized = false
			manager.requestWhenInUseAuthorization()
		case .denied:
			isAuthorized = false
		default:
			isAuthorized = true
			startLocationServices()
		}
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
		print("error: \(error.localizedDescription)")
	}
}

