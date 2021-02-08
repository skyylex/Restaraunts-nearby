//
//  MapViewModelTests.swift
//  RestaurantsTests
//
//  Created by Yury Lapitsky on 05/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import XCTest
import CoreLocation
@testable import Restaurants

final class MapViewModelTests: XCTestCase {
    
    func testCenteringRequestSuccessfull() {
        let accuracy = 0.00001
        let hanoi = CLLocationCoordinate2D.hanoiCity
        
        let provider = SimpleLocationProviderMock()
        provider.lastKnownGPSCoordinate = hanoi
        
        let dependencies = MapViewModel.Dependencies(
            locationProvider: provider,
            searchService: FourSquareServiceMock(),
            showVenueDetailsCallback: { _ in},
            openSettingsApp: {}
        )
        let viewModel = MapViewModel(dependencies: dependencies)
        
        let expectCoordinateForCentering = expectation(description: "Expected a centerMe call")
        
        viewModel.updateZoomLevel = { (_, coordinate) in
            XCTAssertEqual(coordinate.latitude, CLLocationCoordinate2D.hanoiCity.latitude, accuracy: accuracy)
            XCTAssertEqual(coordinate.longitude, CLLocationCoordinate2D.hanoiCity.longitude, accuracy: accuracy)
            
            expectCoordinateForCentering.fulfill()
        }
        viewModel.updateUserLocationVisibility = { _ in}
        viewModel.showPinsOnMap = { _ in }
        viewModel.handleError = { _ in }
        
        viewModel.onCenteringRequest()
        
        wait(for: [expectCoordinateForCentering], timeout: 0.1)
    }
    
    func testCenteringRequestErrored() {
        let provider = SimpleLocationProviderMock()
        let dependencies = MapViewModel.Dependencies(
            locationProvider: provider,
            searchService: FourSquareServiceMock(),
            showVenueDetailsCallback: { _ in},
            openSettingsApp: {}
        )
        let viewModel = MapViewModel(dependencies: dependencies)
        
        let expectedHandleErrorCall = expectation(description: "Expected handleError call")
        
        viewModel.updateZoomLevel = { (_, _) in }
        viewModel.updateUserLocationVisibility = { _ in}
        viewModel.showPinsOnMap = { _ in }
        viewModel.handleError = { coordinate in
            expectedHandleErrorCall.fulfill()
        }
        
        provider.internalAuthorizationStatus = .denied
        
        viewModel.onCenteringRequest()
        
        wait(for: [expectedHandleErrorCall], timeout: 0.1)
    }
    
    func testLocationUpdatesDuringLifecycleEvents() {
        let provider = SimpleLocationProviderMock()
        let dependencies = MapViewModel.Dependencies(
            locationProvider: provider,
            searchService: FourSquareServiceMock(),
            showVenueDetailsCallback: { _ in},
            openSettingsApp: {}
        )
        let viewModel = MapViewModel(dependencies: dependencies)
        
        viewModel.updateZoomLevel = { (_, _) in }
        viewModel.updateUserLocationVisibility = { _ in}
        viewModel.showPinsOnMap = { _ in }
        
        viewModel.handleError = { coordinate in }
        
        provider.internalAuthorizationStatus = .authorizedAlways
        
        XCTAssertFalse(provider.isUpdating)
        
        viewModel.viewLifecyleEventsPublisher.value = ViewLifecycleEvent.viewDidAppear
        
        XCTAssertTrue(provider.isUpdating)
        
        viewModel.viewLifecyleEventsPublisher.value = ViewLifecycleEvent.viewDidDisappear

        XCTAssertFalse(provider.isUpdating)
    }
    
    func testFirstAppearanceCenteringWithError() {
        let provider = SimpleLocationProviderMock()
        let dependencies = MapViewModel.Dependencies(
            locationProvider: provider,
            searchService: FourSquareServiceMock(),
            showVenueDetailsCallback: { _ in},
            openSettingsApp: {}
        )
        let viewModel = MapViewModel(dependencies: dependencies)
        
        let expectErrorHandlingCall = expectation(description: "Expect handleError call when provider returns error")
        
        viewModel.updateZoomLevel = { (_, _) in }
        viewModel.updateUserLocationVisibility = { _ in }
        viewModel.showPinsOnMap = { _ in }
        viewModel.handleError = { _ in
            expectErrorHandlingCall.fulfill()
        }
        
        XCTAssertNil(provider.completion)
        
        viewModel.viewLifecyleEventsPublisher.value = ViewLifecycleEvent.viewDidAppear
        
        XCTAssertNotNil(provider.completion)
        
        provider.completion?(.failure(NSError(domain: "TestError", code: 101, userInfo: [:])))
        
        wait(for: [expectErrorHandlingCall], timeout: 0.1)
    }
    
    func testFirstAppearanceCenteringWithCoordinate() {
        let provider = SimpleLocationProviderMock()
        let dependencies = MapViewModel.Dependencies(
            locationProvider: provider,
            searchService: FourSquareServiceMock(),
            showVenueDetailsCallback: { _ in},
            openSettingsApp: {}
        )
        let viewModel = MapViewModel(dependencies: dependencies)
        
        let expectCenterMeCall = expectation(description: "Expected centerMe call when provider has a coordinate")
        
        viewModel.updateZoomLevel = { (_, _) in
            expectCenterMeCall.fulfill()
        }
        viewModel.updateUserLocationVisibility = { _ in}
        viewModel.showPinsOnMap = { _ in }
        viewModel.handleError = { _ in
            XCTAssertFalse(true, "Should not be called if no error occured")
        }
        
        XCTAssertNil(provider.completion)
        
        viewModel.viewLifecyleEventsPublisher.value = ViewLifecycleEvent.viewDidAppear
        
        XCTAssertNotNil(provider.completion)
        
        provider.completion?(.success(CLLocationCoordinate2D.hanoiCity))
        
        wait(for: [expectCenterMeCall], timeout: 0.1)
    }
    
}
