//
//  MapViewCoordinatorTests.swift
//  RestaurantsTests
//
//  Created by Yury Lapitsky on 05/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import XCTest

@testable import Restaurants

final class MapViewCoordinatorTests: XCTestCase {
    
    func testStart() {
        let window = UIWindow()
        let coordinator = MapViewCoordinator()
        coordinator.start(with: window)
        
        XCTAssertNotNil(window.rootViewController)
        XCTAssertTrue(window.rootViewController is MapViewController)
        XCTAssertNotNil((window.rootViewController as? MapViewController)?.viewModelInput)
        XCTAssertNotNil((window.rootViewController as? MapViewController)?.viewModelOutput)
    }
    
}
