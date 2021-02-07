//
//  FourSquareServiceMock.swift
//  RestaurantsTests
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import CoreLocation
import Combine
@testable import Restaurants

final class FourSquareServiceMock: FourSquareServicing {
    func searchVenues(near coordinate: CLLocationCoordinate2D) -> Future<[FourSquareVenue], FourSquareServiceError> {
        return Future { promise in
            promise(.success([]))
        }
    }
    
    func fetchPhoto(with identifier: String) -> Future<FourSquareVenuePhotoItem?, Never> {
        return Future { promise in
            promise(.success(nil))
        }
    }

}
