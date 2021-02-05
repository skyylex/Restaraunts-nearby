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

/// A simple wrapper over geo-positioning API  to obtain current user location
protocol SimpleLocationProviding {
    /// Initiates start of GPS updates that results in `lastKnownGPSCoordinate` being updated
    /// - Note: GPS updates consume battery and should be disabled with `stopLocationUpdates` if it's not necessary
    func startLocationUpdates()
    
    /// A companion of `startLocationUpdates` that stops GPS updates
    func stopLocationUpdates()
    
    /// One time request to receive GPS Coordiante
    /// - Note: might hang if it's not authorized
    /// - Parameter completion: a callback to receive results from fetch request: either a coordinate or an error
    func fetchCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void)
    
    /// Last saved GPS Coordinate stored from `fetchCurrentLocation()` / `startLocationUpdates()` usage
    var lastKnownGPSCoordinate: CLLocationCoordinate2D? { get }
    
    /// Authorization status to use Location Services
    var isAuthorized: Bool { get }
}

/// Implementation of SimpleLocationProviding based on SwiftLocation
final class SimpleLocationProvider: SimpleLocationProviding {
    
    private var lastLocationRequest: GPSLocationRequest?
    
    func startLocationUpdates() {
        lastLocationRequest = SwiftLocation.gpsLocationWith({ (options) in
            options.subscription = .continous
        })
        
        lastLocationRequest?.then { _ in
            // Do nothing, we're interested in `lastKnownGPSCoordinate` being up-to date
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
        guard isAuthorized else {
            return nil
        }
        
        return SwiftLocation.lastKnownGPSLocation?.coordinate
    }
    
    var isAuthorized: Bool {
        SwiftLocation.authorizationStatus == .authorizedAlways ||
        SwiftLocation.authorizationStatus == .authorizedWhenInUse
    }
    
}
