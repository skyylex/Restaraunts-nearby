//
//  FourSquareService.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 06/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import FoursquareAPIClient
import CoreLocation
import Argo
import Combine

struct FourSquareConfig {
    let clientId = "51AU2XW5IUAR0K1GWLGG240CGV3FOVM4DMUIPP5B2ECGQIUY"
    let clientSecret = "IEJ30XLTOCR2CEZQZDDLYLQ3GTZALPBGCWJVJDQXZ4J5IZ14"
}

protocol FourSquareServicing {
    func search(with coordinate: CLLocationCoordinate2D) -> Future<[FourSquareVenue], Error>
}

/// Documentation for FourSquare search -  https://developer.foursquare.com/docs/api-reference/venues/search/
class FourSquareService: FourSquareServicing {
    private let apiClient: FoursquareAPIClient
    init(config: FourSquareConfig = FourSquareConfig()) {
        apiClient = FoursquareAPIClient(clientId: config.clientId, clientSecret: config.clientSecret)
    }
    
    func search(with coordinate: CLLocationCoordinate2D) -> Future<[FourSquareVenue], Error> {
        let locationString = "\(coordinate.latitude),\(coordinate.longitude)"
        let parameters = [
            "ll": locationString,
            "query": "restaurant"
        ];
        
        return Future { promise in
            self.apiClient.request(path: "venues/search", parameter: parameters) { (result) in
                switch result {
                case .failure(let error):
                    promise(.failure(error))
                case .success(let data):
                    promise(self.venues(from: data))
                }
            }
        }
    }
    
    private func venues(from data: Data) -> Result<[FourSquareVenue], Error> {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let json = json {
            let decoded: Decoded<FourSquareResponse> = decode(json)
            switch decoded {
            case .success(let response):
                return .success(response.response.venues)
            case .failure(let error):
                return .failure(error)
            }
        } else {
            return .failure(NSError(domain: "", code: 123, userInfo: nil))
        }
    }
}
