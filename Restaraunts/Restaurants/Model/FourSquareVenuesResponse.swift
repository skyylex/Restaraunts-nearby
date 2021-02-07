//
//  FourSquareVenuesResponse.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes
import CoreLocation

struct FourSquareVenuesResponse {
    let meta: FourSquareMetaInfo
    let response: FourSquareVenuesInternalResponse
}

extension FourSquareVenuesResponse: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareVenuesResponse> {
        return curry(FourSquareVenuesResponse.init)
            <^> json <| "meta"
            <*> json <| "response"
    }
}

struct FourSquareVenuesInternalResponse {
    let venues: [FourSquareVenue]
}

extension FourSquareVenuesInternalResponse: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareVenuesInternalResponse> {
        return curry(FourSquareVenuesInternalResponse.init)
            <^> json <|| "venues"
    }
}

struct FourSquareLocation {
    let lat: Double
    let lng: Double
//    let address: String?
//    let formattedAddress: [String]?
}

extension FourSquareLocation: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareLocation> {
        return curry(FourSquareLocation.init)
            <^> json <| "lat"
            <*> json <| "lng"
//            <*> json <| "address"
//            <*> json <|| "formattedAddress"
    }
}

struct FourSquareVenue {
    let id: String
    let name: String
    let location: FourSquareLocation
}

extension FourSquareVenue {
    func coordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.lat, longitude: location.lng)
    }
}

extension FourSquareVenue: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareVenue> {
        return curry(FourSquareVenue.init)
            <^> json <| "id"
            <*> json <| "name"
            <*> json <| "location"
    }
}

struct FourSquareMetaInfo {
    let code: Int
    let requestId: String
}

extension FourSquareMetaInfo: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareMetaInfo> {
        return curry(FourSquareMetaInfo.init)
            <^> json <| "code"
            <*> json <| "requestId"
    }
}
