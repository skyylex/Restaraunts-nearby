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
import LocationProvider
import Combine

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
    var authorizationStatus: CLAuthorizationStatus { get }
    
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> { get }
}

/// Implementation of SimpleLocationProviding based on SwiftLocation
final class SimpleLocationProvider: SimpleLocationProviding {
    private var provider: LocationProvider = {
        let provider = LocationProvider(allowsBackgroundLocationUpdates: false)
        provider.onAuthorizationStatusDenied = {}
        return provider
    }()
    
    var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> {
        provider.$authorizationStatus.compactMap { $0}.eraseToAnyPublisher()
    }
    
    private var lastLocationRequest: GPSLocationRequest?
    
    func startLocationUpdates() {
        // Silencing errors, since we use direct access to authorizationStatus
        try? provider.start()
    }
    
    func stopLocationUpdates() {
        provider.stop()
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
        return provider.location?.coordinate
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        return provider.authorizationStatus ?? .notDetermined
    }
    
}
