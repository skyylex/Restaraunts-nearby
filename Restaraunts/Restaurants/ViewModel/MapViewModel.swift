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

enum ZoomLevel: Int {
    case cityLevel = 11
}

final class MapViewModel: ViewModel, MapViewModelInput, MapViewModelOutput {
    struct Dependencies {
        let locationProvider: SimpleLocationProviding
        let searchService: FourSquareServicing
        let showVenueDetailsCallback: (FourSquareVenue) -> Void
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
    private var centeringOnFirstAppearingToken: AnyCancellable?
    private var updatingUserLocationVisibilityToken: AnyCancellable?
    private var restaurantsLoadingOnUserLocationUpdate: AnyCancellable?
    private var zoomingToUserLocationOnAppearingToken: AnyCancellable?
    private var showVenueDetailsCallback: (FourSquareVenue) -> Void
    
    init(dependencies: Dependencies) {
        locationProvider = dependencies.locationProvider
        searchService = dependencies.searchService
        showVenueDetailsCallback = dependencies.showVenueDetailsCallback
        
        super.init()
        
        updatingUserLocationVisibilityToken = locationProvider.authorizationStatusPublisher.sink { [weak self] status in
            guard let self = self else { return }
            
            let shouldBeVisible = status == .authorizedAlways || status == .authorizedWhenInUse
            
            // Updating visibility based on authorization to silence possible alerts from MapKit
            self.updateUserLocationVisibility(shouldBeVisible)
        }
        
        centeringOnFirstAppearingToken = viewDidAppearPublisher.first().sink { [weak self] _ in
            guard let self = self else { return }
            
            self.locationProvider.fetchCurrentLocation { [weak self] (result) in
                switch result {
                case .success(let coordinate):
                    self?.updateZoomLevel(ZoomLevel.cityLevel.rawValue, coordinate)
                case .failure(_):
                    // Authorization errors are checked elsewhere
                    self?.handleError(.generic(title: nil, message: Strings.cannotFetchGPSCoordinate, shouldBlockUI: false))
                }
            }
            
            self.centeringOnFirstAppearingToken = nil
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
        
        restaurantsLoadingOnUserLocationUpdate = locationProvider.currentLocationPublisher.first().zip(viewDidAppearPublisher).sink { [weak self] (coordinate, _) in
            self?.searchRestaurants(near: coordinate)
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
            updateZoomLevel(ZoomLevel.cityLevel.rawValue, coordinate)
            searchRestaurants(near: coordinate)
        } else {
            locationProvider.fetchCurrentLocation { [weak self] (result) in
                switch result {
                case .success(let coordinate):
                    self?.updateZoomLevel(ZoomLevel.cityLevel.rawValue, coordinate)
                case .failure(_):
                    // Authorization errors are checked elsewhere
                    self?.handleError(.generic(title: nil, message: Strings.cannotFetchGPSCoordinate, shouldBlockUI: false))
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
    
    func onShowVenueDetails(with annotation: IdentifiableAnnotation) {
        // MapViewModel placed and can safely retrieve data
        guard let venue = annotation.userInfo as? FourSquareVenue else { fatalError("Something change annotation data") }
        
        showVenueDetailsCallback(venue)
    }
    
    // ViewModelOutput:
    var handleError: (MapViewError) -> Void = {_ in preconditionFailure("handleError: should be overriden by MapView") }
    var updateUserLocationVisibility: (Bool) -> Void = { _ in preconditionFailure("showUserLocation: should be overriden by MapView") }
    var showPinsOnMap: ([IdentifiableAnnotation]) -> Void = {  _ in preconditionFailure("showPinsOnMap: should be overriden by MapView")  }
    var updateZoomLevel: (Int, CLLocationCoordinate2D) -> Void = { _, _ in preconditionFailure("updateZoomLevel: should be overriden by MapView") }

    
    // MARK: Private
    
    private func searchRestaurants(near coordinate: CLLocationCoordinate2D) {
        print("[searchRestaurants] called")
        
        searchingToken = searchService.searchVenues(near: coordinate).eraseToAnyPublisher().sink(receiveCompletion: { [weak self] (completion) in
            switch completion {
            case .failure(let error):
                print("[ERROR] restaurants search failed:\(error.debugMessage)")
                self?.handleError(.generic(title: nil, message: error.message, shouldBlockUI: false))
            case .finished:
                break
            }
        }, receiveValue: { [weak self] (venues) in
            let annotations = venues.map { venue -> IdentifiableAnnotation in
                let annotation = venue.annotation()
                annotation.userInfo = venue
                return annotation
            }
            self?.showPinsOnMap(annotations)
        })
    }
}
