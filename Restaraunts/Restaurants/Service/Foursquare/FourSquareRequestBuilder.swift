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
            case venuesSearch
        }
        
        let path: String
        let parameters: [String: String]
    }
    
    enum Path: String {
        case venuesSearch = "venues/search"
    }
    
    struct ParametersKeys {
        static let locationStringKey = "ll"
        static let queryKey = "query"
    }
    
    struct PrefefinedQuery {
        static let restaurantQuery = "restaurant"
    }
    
    let type: Request.RequestType
    let coordinate: CLLocationCoordinate2D
    
    required init(type: Request.RequestType, coordinate: CLLocationCoordinate2D) {
        self.type = type
        self.coordinate = coordinate
    }
    
    func build() -> Request {
        Request(
            path: path(from: type).rawValue,
            parameters: parameters(from: type)
        )
    }
    
    // MARK: Private
    private func path(from type: Request.RequestType) -> Path {
        switch type {
        case .venuesSearch:
            return .venuesSearch
        }
    }
    
    private func parameters(from type: Request.RequestType) -> [String: String] {
        switch type {
        case .venuesSearch:
            return [
                ParametersKeys.locationStringKey: locationString(from: coordinate),
                ParametersKeys.queryKey: PrefefinedQuery.restaurantQuery,
            ]
        }
    }
    
    private func locationString(from coordinate: CLLocationCoordinate2D) -> String {
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }
}
