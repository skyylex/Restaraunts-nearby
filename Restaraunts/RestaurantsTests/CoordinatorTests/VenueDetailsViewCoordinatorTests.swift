//
//  VenueDetailsViewCoordinatorTests.swift
//  RestaurantsTests
//
//  Created by Yury Lapitsky on 08/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import XCTest
@testable import Restaurants

class UIViewControllerMock: UIViewController {
    var viewControllerToPresent: UIViewController?
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        self.viewControllerToPresent = viewControllerToPresent
    }
}

final class VenueDetailsViewCoordinatorTests: XCTestCase {
    
    func testStart() {
        let venue = FourSquareVenue(
            id: "test-id",
            name: "TestName",
            location: FourSquareLocation(
                lat: 40.0,
                lng: -20.0,
                address: "An unusual address", formattedAddress:["Line 1", "Line 3"]
            )
        )
        
        let coordinator = VenueDetailsViewCoordinator()
        let presenterVC = UIViewControllerMock()
        
        coordinator.start(with: venue, currentVC: presenterVC)
        
        XCTAssertNotNil(presenterVC.viewControllerToPresent)
        XCTAssertNotNil((presenterVC.viewControllerToPresent as? VenueDetailsViewController)?.viewModelInput)
        XCTAssertNotNil((presenterVC.viewControllerToPresent as? VenueDetailsViewController)?.viewModelOutput)
    }
    
}
