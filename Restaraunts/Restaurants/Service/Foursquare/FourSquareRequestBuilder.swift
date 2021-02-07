//
//  FourSquareRequestBuilder.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import CoreLocation

/// Builds all required parameters to use Foursquare service
final class FourSquareRequestBuilder {
    struct Request {
        enum RequestType {
            case venuesSearch(coordinate: CLLocationCoordinate2D)
            case venueDetails(identifier: String)
            
            var path: String {
                switch self {
                case .venueDetails(_):
                    return "venues"
                case .venuesSearch(_):
                    return "venues/search"
                }
            }
        }
        
        let path: String
        let parameters: [String: String]
    }
    
    required init(type: Request.RequestType) {
        self.type = type
    }
    
    func build() -> Request {
        Request(path: type.path, parameters: parameters(from: type))
    }
    
    // MARK: Private
    private func parameters(from type: Request.RequestType) -> [String: String] {
        switch type {
        case .venuesSearch(let coordinate):
            return [
                ParametersKeys.locationStringKey: locationString(from: coordinate),
                ParametersKeys.queryKey: PrefefinedQuery.restaurantQuery,
                ParametersKeys.limitKey: "5", // FIXME:
            ]
        case .venueDetails(let identifier):
            return [
                ParametersKeys.venueIDKey: identifier,
            ]
        }
    }
    
    private func locationString(from coordinate: CLLocationCoordinate2D) -> String {
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }
    
    private struct ParametersKeys {
        static let locationStringKey = "ll"
        static let queryKey = "query"
        static let limitKey = "limit"
        static let venueIDKey = "VENUE_ID"
    }
    
    private struct PrefefinedQuery {
        static let restaurantQuery = "restaurant"
    }
    
    private let type: Request.RequestType
    
}
