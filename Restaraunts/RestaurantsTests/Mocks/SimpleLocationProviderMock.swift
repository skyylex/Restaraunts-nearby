//
//  SimpleLocationProviderMock.swift
//  RestaurantsTests
//
//  Created by Yury Lapitsky on 05/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import CoreLocation
import Combine
@testable import Restaurants

class SimpleLocationProviderMock: SimpleLocationProviding {
    @Published var internalAuthorizationStatus: CLAuthorizationStatus? = nil
    @Published var internalCurrentLocation : CLLocationCoordinate2D? = nil
    
    var currentLocationPublisher: AnyPublisher<CLLocationCoordinate2D, Never> {
        $internalCurrentLocation.compactMap { $0 }.eraseToAnyPublisher()
    }
    
    var authorizationStatus: CLAuthorizationStatus {
        internalAuthorizationStatus ?? .notDetermined
    }
    
    lazy var authorizationStatusPublisher: AnyPublisher<CLAuthorizationStatus, Never> = {
        return $internalAuthorizationStatus.compactMap { $0 }.eraseToAnyPublisher()
    }()
    
    var isAuthorized: Bool = true
    
    var isUpdating = false
    
    func startLocationUpdates() {
        isUpdating = true
    }
    
    func stopLocationUpdates() {
        isUpdating = false
    }
    
    var completion: ((Result<CLLocationCoordinate2D, Error>) -> Void)?
    
    func fetchCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        self.completion = completion
    }
    
    var lastKnownGPSCoordinate: CLLocationCoordinate2D?
    
}
