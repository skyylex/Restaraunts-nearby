//
//  FourSquareServiceTests.swift
//  RestaurantsTests
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import XCTest
import FoursquareAPIClient
import CoreLocation
@testable import Restaurants

class FoursquareAPIMock: FoursquareAPI {
    struct RequestInfo {
        let path: String
        let method: HTTPMethod
        let parameter: [String : String]
        let completion: (Result<Data, FoursquareClientError>) -> Void
    }
    
    var executedRequests = [RequestInfo]()
    
    func request(path: String, method: HTTPMethod, parameter: [String : String], completion: @escaping (Result<Data, FoursquareClientError>) -> Void) {
        executedRequests.append(
            RequestInfo(
                path: path,
                method: method,
                parameter: parameter,
                completion: completion
            )
        )
    }
}

final class FourSquareServiceTests: XCTestCase {
    func testSearchRequest() {
        let apiMock = FoursquareAPIMock()
        let service = FourSquareService(config: FourSquareConfig(), apiClient: apiMock)
        
        XCTAssertEqual(apiMock.executedRequests.count, 0)
        
        _ = service.search(with: FourSquareRequestBuilder(type: .venuesSearch, coordinate: CLLocationCoordinate2D.hanoiCity))
        
        XCTAssertEqual(apiMock.executedRequests.count, 1)
        XCTAssertNotNil(apiMock.executedRequests.first?.completion)
        XCTAssertNotNil(apiMock.executedRequests.first?.method)
        XCTAssertNotNil(apiMock.executedRequests.first?.parameter)
        XCTAssertNotNil(apiMock.executedRequests.first?.path)
    }
    
    func testSuccessullSearch() {
        let apiMock = FoursquareAPIMock()
        let service = FourSquareService(config: FourSquareConfig(), apiClient: apiMock)
        
        let expectVenues = expectation(description: "Expect successfully loaded venues objects")
        
        let resultsPromise = service.search(with: FourSquareRequestBuilder(type: .venuesSearch, coordinate: CLLocationCoordinate2D.newYork))
        let cancellable = resultsPromise.sink { (result) in } receiveValue: { (venues) in
            XCTAssertEqual(venues.count, 1)
            XCTAssertEqual(venues.first?.name, "Mr. Purple")
            expectVenues.fulfill()
        }
        
        apiMock.executedRequests.first?.completion(.success(jsonDataFromSuccessfullSearch()))

        wait(for: [expectVenues], timeout: 0.1)
    }
    
    private func jsonDataFromSuccessfullSearch() -> Data {
        guard let path = Bundle(for: FourSquareServiceTests.self).path(forResource: "foursquare-response", ofType: "json") else {
            fatalError()
        }
        
        return try! NSData(contentsOfFile: path) as Data
    }
}
