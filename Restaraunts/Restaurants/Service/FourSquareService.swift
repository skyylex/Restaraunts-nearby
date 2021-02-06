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

struct FourSquareConfig {
    let clientId = "51AU2XW5IUAR0K1GWLGG240CGV3FOVM4DMUIPP5B2ECGQIUY"
    let clientSecret = "IEJ30XLTOCR2CEZQZDDLYLQ3GTZALPBGCWJVJDQXZ4J5IZ14"
}

protocol FourSquareServicing {
    func search(with coordinate: CLLocationCoordinate2D)
}

/// Documentation for FourSquare search -  https://developer.foursquare.com/docs/api-reference/venues/search/
class FourSquareService: FourSquareServicing {
    private let apiClient: FoursquareAPIClient
    init(config: FourSquareConfig = FourSquareConfig()) {
        apiClient = FoursquareAPIClient(clientId: config.clientId, clientSecret: config.clientSecret)
    }
    
    func search(with coordinate: CLLocationCoordinate2D) {
        let locationString = "\(coordinate.latitude),\(coordinate.longitude)"
        let parameters = [
            "ll": locationString,
            "query": "restaurant"
        ];
        
        apiClient.request(path: "venues/search", parameter: parameters) { (result) in
            print("Result: \(result)")
            switch result {
            case.failure(let error):
                print(error)
                break;
            case .success(let data):
                let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
                
                print(json)
                break;
            }
        }
    }
}
