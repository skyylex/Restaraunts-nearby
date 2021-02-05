//
//  MapViewModel.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 05/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

final class MapViewModel: MapViewModelInput, MapViewModelOutput {
    struct Dependencies {
        let locationProvider: SimpleLocationProviding
    }
    
    private static let defaultMessage = "Cannot fetch current user location"
    private let locationProvider: SimpleLocationProviding
    private var isFirstAppearance = true
    
    init(dependencies: Dependencies) {
        locationProvider = dependencies.locationProvider
    }
    
    // ViewModelInput:
    func onCenteringRequest() {
        guard let coordinate = locationProvider.lastKnownGPSCoordinate else {
            handleError(.generic(message: Self.defaultMessage))
            return
        }
        
        centerMe(coordinate)
    }
    
    func onViewDidAppear() {
        if isFirstAppearance {
            locationProvider.fetchCurrentLocation { [weak self] (result) in
                switch result {
                case .success(let coordinate):
                    self?.centerMe(coordinate)
                case .failure(let error):
                    self?.handleError(.generic(message: error.localizedDescription))
                }
            }
            
            isFirstAppearance = false
        }

        locationProvider.startLocationUpdates()
    }
    
    func onSettingsAppOpeningRequest() {
        // TODO: move to Coordinator
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // ViewModelOutput:
    var handleError: (MapViewError) -> Void = {_ in preconditionFailure("handleError: should be overriden by MapView") }
    var centerMe: (CLLocationCoordinate2D) -> Void = { _ in preconditionFailure("centerMe: should be overriden by MapView") }
    
}
