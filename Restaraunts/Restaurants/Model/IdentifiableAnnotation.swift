//
//  IdentifiableAnnotation.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import MapKit

protocol IdentifiableAnnotation: MKAnnotation {
    var identifier: String { get }
    
    var userInfo: Any?  { get set }
}
