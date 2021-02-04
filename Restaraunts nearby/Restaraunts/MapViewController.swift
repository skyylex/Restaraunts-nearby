//
//  MapViewController.swift
//  Restaraunts nearby
//
//  Created by Yury Lapitsky on 04/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import UIKit
import MapKit
import SwiftLocation

extension UIColor {
    static let brightBlue = UIColor(red: 31.0 / 255.0, green: 116.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    static let almostWhite = UIColor(red: 239.0 / 255.0, green: 238.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0)
}

final class MapViewController: UIViewController {
    
    private enum Error {
        case locationServicesUnavailable
        
        var message: String {
            switch self {
            case .locationServicesUnavailable:
                return """
                    Location Services are unavailable. If you want to use your geo-location: \n\n 1. Go to \"Settings\". \n 2. Go to \"Privacy\". \n 3. Choose \"Location Services\". \n 4. Turn \"Location services\" on.
                    """
            }
        }
    }

    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }()
    
    private var centerButton: UIButton = {
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
        
        button.addTarget(self, action: #selector(centerMe), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attachMapView()
        attachMapControls()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if SwiftLocation.authorizationStatus == .denied {
            handleError(.locationServicesUnavailable)
            return
        }
        
        SwiftLocation.gpsLocationWith({ (options) in
            options.subscription = .single
        }).then { [weak self] (result) in
            self?.centerMe()
        }
        
        SwiftLocation.gpsLocationWith({ (options) in
            options.subscription = .continous
        }).then { _ in
            // Continue getting updates to have a fast re-centering over user location
        }
    }
    
    // MARK: Views attachment
    
    private func attachMapControls() {
        view.addSubview(centerButton)
        centerButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            centerButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            centerButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func attachMapView() {
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
    
    // MARK: Alerts
    
    private func showAlert(title: String, message: String) {
        let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(openSettingsAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }

    // MARK: Actions
    
    @objc private func centerMe() {
        guard let coordinate = SwiftLocation.lastKnownGPSLocation?.coordinate else {
            // TODO: handle error here
            return
        }
        
        mapView.centerCoordinate = coordinate
    }
    
    // MARK: Error handling
    
    private func handleError(_ error: Error) {
        switch error {
        case .locationServicesUnavailable:
            showAlert(title: "Error", message: error.message)
        }
    }

}

