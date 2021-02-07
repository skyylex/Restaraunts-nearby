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
    enum Mode {
        case regular
        case increased
    }
    
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
        
        image = draw(mode: (self.isSelected) ? .increased : .regular)
        
        let label = createLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        let constraints = [
            bottomAnchor.constraint(equalTo: label.topAnchor),
            centerXAnchor.constraint(equalTo: label.centerXAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.image = self.draw(mode: selected ? .increased : .regular)
            }
        }
        
        image = draw(mode: selected ? .increased : .regular)
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.text = annotation?.title ?? ""
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .brightBlue
        return label
    }

    private func drawImage(_ iconImage: UIImage, stripeColor: UIColor, mode: Mode) -> UIImage {
        let defaultSize = CGSize(width: 28.0, height: 28.0)
        let increasedSize = CGSize(width: 48.0, height: 48.0)
        
        let totalSize = (mode == .increased) ? increasedSize : defaultSize
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: totalSize.width, height: totalSize.height))
        return renderer.image { _ in
            // Outer stripe is the first circle
            stripeColor.setFill()
            UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: totalSize.width, height: totalSize.height)).fill()
            
            // Draw icon
            let iconSize = CGSize(width: totalSize.width / 2, height: totalSize.height / 2)
            let rect = CGRect(
                x: iconSize.width - iconSize.width / 2,
                y: iconSize.height - iconSize.height / 2,
                width: iconSize.width,
                height: iconSize.height
            )
            iconImage.draw(in: rect)
        }
    }
    
    private func draw(mode: Mode) -> UIImage {
        // TODO: fix force unwrap
        let icon = UIImage(named: "restaurant")?.withTintColor(UIColor.white)
        return drawImage(icon!, stripeColor: UIColor.brightBlue, mode: mode)
    }

    private func count() -> Int {
        guard let cluster = annotation as? MKClusterAnnotation else {
            return 0
        }

        return cluster.memberAnnotations.count
    }
}
