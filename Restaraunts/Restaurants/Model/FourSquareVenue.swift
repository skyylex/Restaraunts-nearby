//
//  Venue.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 06/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import Argo
import Curry
import Runes

struct FourSquareLocation {
    let address: String
    let lat: Int
    let lng: Int
    let formattedAddress: [String]
}

extension FourSquareLocation: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareLocation> {
        return curry(FourSquareLocation.init)
            <^> json <| "address"
            <*> json <| "lat"
            <*> json <| "lng"
            <*> json <|| "formattedAddress"
    }
}

struct FourSquareVenue {
    let id: String
    let name: String
    let location: FourSquareLocation
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

struct FourSquareInternalResponse {
    let venues: [FourSquareVenue]
}

extension FourSquareInternalResponse: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareInternalResponse> {
        return curry(FourSquareInternalResponse.init)
            <^> json <|| "venues"
    }
}

struct FourSquareResponse {
    let meta: FourSquareMetaInfo
    let response: FourSquareInternalResponse
}

extension FourSquareResponse: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareResponse> {
        return curry(FourSquareResponse.init)
            <^> json <| "meta"
            <*> json <| "response"
    }
}
