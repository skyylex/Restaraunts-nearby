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
import Combine
import MapKit

final class MapViewModel: ViewModel, MapViewModelInput, MapViewModelOutput {
    struct Dependencies {
        let locationProvider: SimpleLocationProviding
        let searchService: FourSquareServicing
    }
    
    struct Strings {
        static let cannotFetchGPSCoordinate = "Cannot fetch GPS coordinate"
        
        static let locationServicesAreDisabledTitle = "Location Services are disabled"
        static let locationServicesAreDisabledMessage = """
            Please turn Locations Services to benefit from more relevant search results:\n
            1. Open "Settings" app
            2. Go to "Privacy"
            3. Set "Location Services" to "While using the app"
        """
    }
    
    private let locationProvider: SimpleLocationProviding
    private let searchService: FourSquareServicing
    
    // MARK: Subscriptions tokens
    private var startMonitoringEventsToken: AnyCancellable?
    private var stopMonitoringEventsToken: AnyCancellable?
    private var centeringOnFirstAppearingToke: AnyCancellable?
    private var updatingUserLocationVisibilityToken: AnyCancellable?
    
    init(dependencies: Dependencies) {
        locationProvider = dependencies.locationProvider
        searchService = dependencies.searchService
        
        super.init()
        
        updatingUserLocationVisibilityToken = locationProvider.authorizationStatusPublisher.sink { [weak self] status in
            guard let self = self else { return }
            
            let shouldBeVisible = status == .authorizedAlways || status == .authorizedWhenInUse
            
            // Updating visibility based on authorization to silence possible alerts from MapKit
            self.updateUserLocationVisibility(shouldBeVisible)
        }
        
        centeringOnFirstAppearingToke = viewDidAppearPublisher.first().sink { [weak self] _ in
            guard let self = self else { return }
            
            self.locationProvider.fetchCurrentLocation { [weak self] (result) in
                switch result {
                case .success(let coordinate):
                    self?.centerMe(coordinate)
                case .failure(let error):
                    self?.handleError(.generic(title: nil, message: error.localizedDescription, shouldBlockUI: false))
                }
            }
            
            self.centeringOnFirstAppearingToke = nil
        }
        
        startMonitoringEventsToken = viewDidAppearPublisher.merge(with: appDidBecomeActive).zip(locationProvider.authorizationStatusPublisher).sink { [weak self] (_, status) in
            guard let self = self else { return }
            
            if status == .authorizedAlways || status == .authorizedWhenInUse || status == .notDetermined {
                self.locationProvider.startLocationUpdates()
            }
        }
        
        stopMonitoringEventsToken = viewDidDisappearPublisher.merge(with: appWillResignActive).sink { [weak self] _ in
            self?.locationProvider.stopLocationUpdates()
        }
    }
    
    // ViewModelInput:
    private var searchingToken: AnyCancellable?
    
    func onCenteringRequest() {
        if self.locationProvider.authorizationStatus == .denied {
            self.handleError(.locationServicesNotAuthorized(
                                title: Strings.locationServicesAreDisabledTitle,
                                message: Strings.locationServicesAreDisabledMessage,
                                shouldBlockUI: true))
        }
        
        if let coordinate = locationProvider.lastKnownGPSCoordinate {
            centerMe(coordinate)
            searchRestaurants(near: coordinate)
        } else {
            locationProvider.fetchCurrentLocation { [weak self] (result) in
                switch result {
                case .success(let coordinate):
                    self?.centerMe(coordinate)
                case .failure(let error):
                    self?.handleError(.generic(title: nil, message: error.localizedDescription, shouldBlockUI: false))
                }
            }
        }
    }
    
    func onSettingsAppOpeningRequest() {
        // TODO: move to Coordinator
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func onVisibleRegionChanged(regionCenter: CLLocationCoordinate2D, latDelta: CLLocationDegrees, lngDelta: CLLocationDegrees) {
        searchRestaurants(near: regionCenter)
    }
    
    // ViewModelOutput:
    var handleError: (MapViewError) -> Void = {_ in preconditionFailure("handleError: should be overriden by MapView") }
    var centerMe: (CLLocationCoordinate2D) -> Void = { _ in preconditionFailure("centerMe: should be overriden by MapView") }
    var updateUserLocationVisibility: (Bool) -> Void = { _ in preconditionFailure("showUserLocation: should be overriden by MapView") }
    var showPinsOnMap: ([MKAnnotation]) -> Void = {  _ in preconditionFailure("showPinsOnMap: should be overriden by MapView")  }
    
    // MARK: Private
    
    private func searchRestaurants(near coordinate: CLLocationCoordinate2D) {
        let requestBuilder = FourSquareRequestBuilder(type: .venuesSearch, coordinate: coordinate)
        
        searchingToken = searchService.search(with: requestBuilder).eraseToAnyPublisher().sink(receiveCompletion: { (completion) in
            switch completion {
            case .failure(let error):
                break
            case .finished:
                break
            }
        }, receiveValue: { (venues) in
            let annotations = venues.map { $0.annotation() }
            self.showPinsOnMap(annotations)
        })
    }
}
