//
//  RootCoordinatorTests.swift
//  RestaurantsTests
//
//  Created by Yury Lapitsky on 05/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import XCTest

@testable import Restaurants

final class RootCoordinatorTests: XCTestCase {
    
    func testStart() {
        let window = UIWindow()
        let coordinator = RootCoordinator()
        coordinator.start(with: window)
        
        XCTAssertNotNil(window.rootViewController)
    }
    
}
