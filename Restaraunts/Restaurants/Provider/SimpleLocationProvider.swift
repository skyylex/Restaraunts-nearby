//
//  SimpleLocationProvider.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 05/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftLocation

protocol SimpleLocationProviding {
    func startLocationUpdates()
    func stopLocationUpdates()
    
    func fetchCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void)
    
    var lastKnownGPSCoordinate: CLLocationCoordinate2D? { get }
}

/// Implementation of SimpleLocationProviding based on SwiftLocation
final class SimpleLocationProvider: SimpleLocationProviding {
    
    private var lastLocationRequest: GPSLocationRequest?
    
    func startLocationUpdates() {
        lastLocationRequest = SwiftLocation.gpsLocationWith({ (options) in
            options.subscription = .continous
        })
        
        lastLocationRequest?.then { _ in
            // Continue getting updates to have a fast re-centering over user location
        }
    }
    
    func stopLocationUpdates() {
        lastLocationRequest?.cancelRequest()
        lastLocationRequest = nil
    }
    
    func fetchCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        SwiftLocation.gpsLocationWith({ (options) in
            options.subscription = .single
        }).then { (result) in
            switch result {
            case .success(let data):
                completion(.success(data.coordinate))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    var lastKnownGPSCoordinate: CLLocationCoordinate2D? {
        SwiftLocation.lastKnownGPSLocation?.coordinate
    }
    
}
