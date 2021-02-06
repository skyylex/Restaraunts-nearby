//
//  FourSquareVenue+MKAnnotation.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 06/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import MapKit

extension FourSquareVenue {
    private class MKAnnotationData: NSObject, MKAnnotation {
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var subtitle: String?
        
        init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String? = nil) {
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
            super.init()
        }
    }
    
    func annotation() -> MKAnnotation {
        MKAnnotationData(coordinate: coordinate(), title: name)
    }
}
