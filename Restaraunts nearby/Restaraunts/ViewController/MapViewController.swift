//
//  MapViewController.swift
//  Restaraunts nearby
//
//  Created by Yury Lapitsky on 04/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import UIKit
import MapKit
import Combine
import CombineCocoa
import GSMessages

extension UIColor {
    static let brightBlue = UIColor(red: 31.0 / 255.0, green: 116.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0)
    static let almostWhite = UIColor(red: 239.0 / 255.0, green: 238.0 / 255.0, blue: 235.0 / 255.0, alpha: 1.0)
}

enum MapViewError {
    case generic(message: String)
}

extension MapViewError {
    var message: String {
        switch self {
        case .generic(let message):
            return message
        }
    }
}

protocol MapViewModelInput {
    func onViewDidAppear()
    func onSettingsAppOpeningRequest()
    func onCenteringRequest()
}

protocol MapViewModelOutput {
    var handleError: (MapViewError) -> Void { get set }
    var centerMe: (CLLocationCoordinate2D) -> Void { get set }
}

final class MapViewController: UIViewController {

    private let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        return mapView
    }()
    
    private var centerButtonTapToken: AnyCancellable?
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
        
        return button
    }()
    
    var viewModelInput: MapViewModelInput!
    var viewModelOutput: MapViewModelOutput!
    
    // MARK: UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attachMapView()
        attachMapControls()
        
        setupViewModelOutput()
        setupViewModelInput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModelInput.onViewDidAppear()
    }
    
    // MARK: Setup view model
    
    private func setupViewModelOutput() {
        viewModelOutput.handleError = { [weak self] error in
            let font = UIFont.boldSystemFont(ofSize: 16)
            let attributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.strokeColor: UIColor.white,
            ]
            
            let attributedString = NSAttributedString(string: error.message, attributes: attributes)
            self?.view.showMessage(attributedString, type: .error)
        }
        
        viewModelOutput.centerMe = { [weak self] coordinate in
            self?.mapView.centerCoordinate = coordinate
        }
    }
    
    // MARK: Actions
    
    private func setupViewModelInput() {
        centerButtonTapToken = centerButton.tapPublisher.sink { [weak self] in
            self?.viewModelInput.onCenteringRequest()
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
        let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { [weak self] (action) in
            self?.viewModelInput.onSettingsAppOpeningRequest()
        }
        let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(openSettingsAction)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

