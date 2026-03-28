//
//  ContentView.swift
//  Architecture
//
//  Created by Anastasia Myropolska on 28.03.26.
//

import SwiftUI

struct ContentView: View {
	@State private var viewModel = ContentViewModel()

	var body: some View {
		ZStack {
			MapView()

			if !viewModel.isLocationServicesEnabled {
				VStack {
					LocationDisabledBanner()
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
			}
		}
	}
}

