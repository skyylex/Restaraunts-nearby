//
//  FourSquareVenue+MKAnnotation.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 06/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import MapKit

class MKAnnotationData: NSObject, DataContainerAnnotation {
    var userInfo: Any?
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        super.init()
    }
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine("\(coordinate.latitude),\(coordinate.longitude)")
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let annotation = object as? MKAnnotationData else { return false }
        
        return coordinate.latitude.isEqual(to: annotation.coordinate.latitude) &&
            coordinate.longitude.isEqual(to: annotation.coordinate.longitude)
    }
}

extension FourSquareVenue {
    func annotation() -> MKAnnotationData {
        MKAnnotationData(coordinate: coordinate(), title: name)
    }

}
