//
//  ViewModelTests.swift
//  RestaurantsTests
//
//  Created by Yury Lapitsky on 06/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import XCTest
import Combine

@testable import Restaurants

final class ViewModelTests: XCTestCase {
    
    func testShortcuts() {
        var tokens = [AnyCancellable]()
        let viewModel = ViewModel()
        
        let expectedThreeViewAppearing = expectation(description: "Expect 3 viewDidAppear calls")
        let expectedTwoViewAppearing = expectation(description: "Expect 2 viewDidDisappear calls")
        
        expectedThreeViewAppearing.expectedFulfillmentCount = 3
        expectedTwoViewAppearing.expectedFulfillmentCount = 2
        
        tokens.append(viewModel.viewDidAppearPublisher.sink { _ in
            expectedThreeViewAppearing.fulfill()
        })
        
        tokens.append(viewModel.viewDidDisappearPublisher.sink { _ in
            expectedTwoViewAppearing.fulfill()
        })
        
        viewModel.viewLifecyleEventsPublisher.value = nil
        viewModel.viewLifecyleEventsPublisher.value = .viewDidLoad
        viewModel.viewLifecyleEventsPublisher.value = .viewDidAppear
        viewModel.viewLifecyleEventsPublisher.value = .viewDidDisappear
        viewModel.viewLifecyleEventsPublisher.value = .viewDidAppear
        viewModel.viewLifecyleEventsPublisher.value = .viewDidDisappear
        viewModel.viewLifecyleEventsPublisher.value = .viewDidAppear
        
        wait(for: [expectedTwoViewAppearing, expectedThreeViewAppearing], timeout: 0.1)
    }
}
