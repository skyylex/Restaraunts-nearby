//
//  IdentifiableAnnotation.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import MapKit

/// A simple extension of original annotation with userInfo added
protocol DataContainerAnnotation: MKAnnotation {
    var userInfo: Any?  { get set }
}
