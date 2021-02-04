//
//  MapViewController.swift
//  Restaraunts nearby
//
//  Created by Yury Lapitsky on 04/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import UIKit
import MapKit

extension UIColor {
    static let brightBlue = UIColor(red: 31.0 / 255.0, green: 116.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    static let almostWhite = UIColor(red: 239.0 / 255.0, green: 238.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0)
}

class MapViewController: UIViewController {

    let mapView = MKMapView()
    
    var centerButton: UIButton = {
        let offset: CGFloat = 5.0;
            
        let image = UIImage(named: "center-button")?.withTintColor(UIColor.brightBlue)
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets.init(top: offset, left: offset, bottom: offset, right: offset)
        button.imageEdgeInsets = UIEdgeInsets.init(top: offset, left: offset, bottom: offset, right: offset)
        button.backgroundColor = UIColor.almostWhite
        button.layer.cornerRadius = 10
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.15
        button.layer.shadowOffset = .zero
        button.layer.shadowRadius = 10
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attachMapView()
        attachMapControls()
    }
    
    func attachMapControls() {
        view.addSubview(centerButton)
        centerButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            centerButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func attachMapView() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    


}

