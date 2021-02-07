//
//  FoursquareAPIClient+Protocols.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import FoursquareAPIClient

extension FoursquareAPIClient: FoursquareAPI { }

protocol FoursquareAPI {
    func request(path: String,
                 method: HTTPMethod,
                 parameter: [String: String],
                 completion: @escaping (Result<Data, FoursquareClientError>) -> Void
    )
}
