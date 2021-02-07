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
import CoreLocation

struct FourSquareVenuePhotoItem {
    let id: String
    let prefix: String
    let suffix: String
}

extension FourSquareVenuePhotoItem: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareVenuePhotoItem> {
        return curry(FourSquareVenuePhotoItem.init)
            <^> json <| "id"
            <*> json <| "prefix"
            <*> json <| "suffix"
    }
}

struct FourSquareVenuePhotos {
    let count: Int
    let items: [FourSquareVenuePhotoItem]
}

extension FourSquareVenuePhotos: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareVenuePhotos> {
        return curry(FourSquareVenuePhotos.init)
            <^> json <| "count"
            <*> json <|| "items"
    }
}

struct FourSquareVenuePhotosResponse {
    let meta: FourSquareMetaInfo
    let response: FourSquareVenuePhotosInternalResponse
}

extension FourSquareVenuePhotosResponse: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareVenuePhotosResponse> {
        return curry(FourSquareVenuePhotosResponse.init)
            <^> json <| "meta"
            <*> json <| "response"
    }
}

struct FourSquareVenuePhotosInternalResponse {
    let photos: FourSquareVenuePhotos
}

extension FourSquareVenuePhotosInternalResponse: Decodable {
    static func decode(_ json: JSON) -> Decoded<FourSquareVenuePhotosInternalResponse> {
        return curry(FourSquareVenuePhotosInternalResponse.init)
            <^> json <| "photos"
    }
}
