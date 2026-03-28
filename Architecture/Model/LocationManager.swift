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
	
	@ObservationIgnored let manager = CLLocationManager()
	var isAuthorized = false

	override init() {
		super.init()
		manager.delegate = self
	}
	
	// MARK: - CLLocationManagerDelegate
	
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		let status = manager.authorizationStatus
		
		switch status {
		case .authorizedAlways, .authorizedWhenInUse:
			isAuthorized = true
		case .notDetermined:
			isAuthorized = false
		case .denied:
			isAuthorized = false
		default:
			isAuthorized = true
		}
	}
	

}

