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

protocol FourSquareServicing {
    func searchVenues(near coordinate: CLLocationCoordinate2D) -> Future<[FourSquareVenue], FourSquareServiceError>
    func fetchPhoto(with identifier: String) -> Future<FourSquareVenuePhotoItem?, Never>
}

enum FourSquareServiceError: Error {
    case jsonConversion(additionalInfo: String)
    case fetching(additionalInfo: String)
    
    var message: String {
        switch self {
        case .fetching:
            return "Cannot download venues from Foursquare"
        case .jsonConversion:
            return "Cannot parse data about Restaurants"
        }
    }
    
    var debugMessage: String {
        switch self {
        case .fetching(let additionalMessage):
            return "Cannot download venues from Foursquare: \(additionalMessage)"
        case .jsonConversion(let additionalMessage):
            return "Cannot parse data about Restaurants \(additionalMessage)"
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

extension FoursquareClientError {
    var description: String {
        switch self {
        case .apiError(let error):
            return "[FoursquareClientError]: \(error.errorType) \(error.errorType)"
        case .connectionError(let error):
            return "[FoursquareClientError]: \(error.localizedDescription)"
        case .responseParseError(let error):
            return "[FoursquareClientError]: \(error.localizedDescription)"
        }
    }
}

/// Service to perform search requests to FourSquare
/// - Note: Documentation for FourSquare search -  `https://developer.foursquare.com/docs/api-reference/venues/search/`
final class FourSquareService: FourSquareServicing {
    private let apiClient: FoursquareAPI
    
    required init(config: FourSquareConfig = FourSquareConfig(), apiClient: FoursquareAPI) {
        self.apiClient = apiClient
    }
    
    func searchVenues(near coordinate: CLLocationCoordinate2D) -> Future<[FourSquareVenue], FourSquareServiceError> {
        let builder = FourSquareRequestBuilder(type: .venuesSearch(coordinate: coordinate))
        
        return requestVenues(with: builder)
    }
    
    func fetchPhoto(with identifier: String) -> Future<FourSquareVenuePhotoItem?, Never> {
        let builder = FourSquareRequestBuilder(type: .venuePhoto(identifier: identifier))
        
        return requestVenuePhoto(with: builder)
    }
    
    private func requestVenuePhoto(with requestBuilder: FourSquareRequestBuilder) -> Future<FourSquareVenuePhotoItem?, Never> {
        let request = requestBuilder.build()
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.apiClient.request(path: request.path, method: .get, parameter: request.parameters) { (result) in
                switch result {
                case .failure(let error):
                    print("[ERROR] requestVenuePhoto: \(error)")
                    promise(.success(nil))
                case .success(let data):
                    promise(self.venuePhoto(from: data))
                }
            }
        }
    }
    
    private func requestVenues(with requestBuilder: FourSquareRequestBuilder) -> Future<[FourSquareVenue], FourSquareServiceError> {
        let request = requestBuilder.build()
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            self.apiClient.request(path: request.path, method: .get, parameter: request.parameters) { (result) in
                switch result {
                case .failure(let error):
                    promise(.failure(FourSquareServiceError.fetching(additionalInfo: error.description)))
                case .success(let data):
                    promise(self.venues(from: data))
                }
            }
        }
    }
    
    private func venuePhoto(from data: Data) -> Result<FourSquareVenuePhotoItem?, Never> {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let json = json {
            let decoded: Decoded<FourSquareVenuePhotosResponse> = decode(json)
            switch decoded {
            case .success(let response):
                return .success(response.response.photos.items.first)
            case .failure(let error):
                print("[ERROR] venuePhoto: \(error)")
                return .success(nil)
            }
        } else {
            print("[ERROR] venuePhoto: no json")
            return .success(nil)
        }
    }
    
    private func venues(from data: Data) -> Result<[FourSquareVenue], FourSquareServiceError> {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let json = json {
            let decoded: Decoded<FourSquareVenuesResponse> = decode(json)
            switch decoded {
            case .success(let response):
                return .success(response.response.venues)
            case .failure(let error):
                return .failure(.jsonConversion(additionalInfo: error.description))
            }
        } else {
            return .failure(FourSquareServiceError.jsonConversion(additionalInfo: "Data is not a JSON object"))
        }
    }
}
