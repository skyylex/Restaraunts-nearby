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
    func search(with requestBuilder: FourSquareRequestBuilder) -> Future<[FourSquareVenue], FourSquareServiceError>
}

enum FourSquareServiceError: Error {
    case jsonConversion(additionalInfo: String)
    case fetching(additionalInfo: String)
    
    var message: String {
        switch self {
        case .fetching:
            return "Downloading error. Check your connection"
        case .jsonConversion:
            return "Cannot parse data about Restaurants"
        }
    }
    
    var code: Int {
        switch self {
        case .fetching(_):
            return 301
        case .jsonConversion(_):
            return 302
        }
    }
}

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
    
    init(type: Request.RequestType, coordinate: CLLocationCoordinate2D) {
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

/// Service to perform search requests to FourSquare
/// - Note: Documentation for FourSquare search -  `https://developer.foursquare.com/docs/api-reference/venues/search/`
final class FourSquareService: FourSquareServicing {
    private let apiClient: FoursquareAPIClient
    
    init(config: FourSquareConfig = FourSquareConfig()) {
        apiClient = FoursquareAPIClient(clientId: config.clientId, clientSecret: config.clientSecret)
    }
    
    func search(with requestBuilder: FourSquareRequestBuilder) -> Future<[FourSquareVenue], FourSquareServiceError> {
        let request = requestBuilder.build()
        return Future { promise in
            self.apiClient.request(path: request.path, parameter: request.parameters) { (result) in
                switch result {
                case .failure(let error):
                    promise(.failure(FourSquareServiceError.fetching(additionalInfo: error.localizedDescription)))
                case .success(let data):
                    promise(self.venues(from: data))
                }
            }
        }
    }
    
    private func venues(from data: Data) -> Result<[FourSquareVenue], FourSquareServiceError> {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let json = json {
            let decoded: Decoded<FourSquareResponse> = decode(json)
            switch decoded {
            case .success(let response):
                return .success(response.response.venues)
            case .failure(let error):
                return .failure(.jsonConversion(additionalInfo: error.localizedDescription))
            }
        } else {
            return .failure(FourSquareServiceError.jsonConversion(additionalInfo: "Data is not a JSON object"))
        }
    }
}
