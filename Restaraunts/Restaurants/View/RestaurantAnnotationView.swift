//
//  RestaurantAnnotationView.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 06/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import MapKit

class RestaurantAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        clusteringIdentifier = "\(RestaurantAnnotationView.self)"
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// - Tag: CustomCluster
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        let brightBlue = UIColor(red: 26.0 / 255.0, green: 119.0 / 255.0, blue: 198.0 / 255.0, alpha: 1.0)
        // TODO: fix force unwrap
        let icon = UIImage(named: "restaurant")?.withTintColor(UIColor.white)
        image = drawImage(icon!, stripeColor: brightBlue)
    }

    private func drawImage(_ iconImage: UIImage, stripeColor: UIColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 28, height: 28))
        return renderer.image { _ in
            // Outer stripe is the first circle
            stripeColor.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 28, height: 28)).fill()
            
            // Draw icon
            let size = CGSize(width: 14, height: 14)
            let rect = CGRect(x: 14 - size.width / 2, y: 14 - size.height / 2, width: size.width, height: size.height)
            iconImage.draw(in: rect)
        }
    }

    private func count() -> Int {
        guard let cluster = annotation as? MKClusterAnnotation else {
            return 0
        }

        return cluster.memberAnnotations.count
    }
}
