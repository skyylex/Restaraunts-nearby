//
//  VenueDetailsViewModelTests.swift
//  RestaurantsTests
//
//  Created by Yury Lapitsky on 08/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import XCTest
@testable import Restaurants

final class VenueDetailsViewModelTests: XCTestCase {
    func testDoesNothingWithoutLifecycleEvents() {
        let serviceMock = FourSquareServiceMock()
        let venue = createVenue()
        let viewModel = VenueDetailsViewModel(venue: venue, fourSquareService:serviceMock)
        
        let expectNoCalls = expectation(description: "VenueDetailsViewModel does nothing without lifecycle events")
        expectNoCalls.isInverted = true
        
        viewModel.showTextDetails = { _ in
            expectNoCalls.fulfill()
        }
        viewModel.showVenueImage = { _ in
            expectNoCalls.fulfill()
        }
        viewModel.stopSpinner = {
            expectNoCalls.fulfill()
        }
        viewModel.startSpinner = {
            expectNoCalls.fulfill()
        }
        
        wait(for: [expectNoCalls], timeout: 0.1)
    }
    
    func testSetsDetailsOnViewDidLoad() {
        let serviceMock = FourSquareServiceMock()
        let venue = createVenue()
        let viewModel = VenueDetailsViewModel(venue: venue, fourSquareService:serviceMock)
        
        let expectTextDetails = expectation(description: "VenueDetailsViewModel sets TextDetails on viewDidLoad")
        let expectStartOfSpinner = expectation(description: "VenueDetailsViewModel launches startsSpinner on viewDidLoad")
        
        viewModel.showTextDetails = { textDetails in
            XCTAssertEqual(textDetails.title, venue.name)
            venue.location.formattedAddress!.forEach { XCTAssertTrue(textDetails.address.contains($0)) }
            
            expectTextDetails.fulfill()
        }
        viewModel.showVenueImage = { _ in
            XCTAssertFalse(true, "This call is not expected")
        }
        viewModel.stopSpinner = {
            XCTAssertFalse(true, "This call is not expected")
        }
        viewModel.startSpinner = {
            expectStartOfSpinner.fulfill()
        }
        
        viewModel.viewLifecyleEventsPublisher.value = .viewDidLoad
        
        wait(for: [expectTextDetails, expectStartOfSpinner], timeout: 0.1)
    }
    
    private func createVenue() -> FourSquareVenue {
        FourSquareVenue(
            id: "test-id",
            name: "TestName",
            location: FourSquareLocation(
                lat: 40.0,
                lng: -20.0,
                address: "An unusual address", formattedAddress:["Line 1", "Line 3"]
            )
        )
    }
}
