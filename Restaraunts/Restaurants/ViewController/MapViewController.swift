//
//  MapViewController.swift
//  Restaurants nearby
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
    case generic(title: String?, message: String, shouldBlockUI: Bool)
    case locationServicesNotAuthorized(title: String, message: String, shouldBlockUI: Bool)
}

extension MapViewError {
    var shouldBlockUI: Bool {
        switch self {
        case .generic(_, _, let shouldBlockUI):
            return shouldBlockUI
        case .locationServicesNotAuthorized(_, _, let shouldBlockUI):
            return shouldBlockUI
        }
    }
    
    var message: String {
        switch self {
        case .generic(_, let message, _):
            return message
        case .locationServicesNotAuthorized(_, let message, _):
            return message
        }
    }
    
    var title: String? {
        switch self {
        case .generic(let title,_ ,_):
            return title
        case .locationServicesNotAuthorized(let title,_,_):
            return title
        }
    }
}

enum ViewLifecycleEvent {
    case viewDidLoad
    case viewDidAppear
    case viewDidDisappear
}

protocol MapViewModelInput: ViewModelInput {
    func onSettingsAppOpeningRequest()
    func onCenteringRequest()
    func onVisibleRegionChanged(regionCenter: CLLocationCoordinate2D, latDelta: CLLocationDegrees, lngDelta: CLLocationDegrees)
}

protocol MapViewModelOutput {
    var handleError: (MapViewError) -> Void { get set }
    var centerMe: (CLLocationCoordinate2D) -> Void { get set }
    var updateUserLocationVisibility: (Bool) -> Void { get set }
    var showPinsOnMap: ([MKAnnotation]) -> Void { get set }
}

final class MapViewController: UIViewController, MKMapViewDelegate {

    private let mapView = MKMapView()
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
        
        viewModelInput.viewLifecyleEventsPublisher.value = .viewDidLoad
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModelInput.viewLifecyleEventsPublisher.value = .viewDidAppear
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModelInput.viewLifecyleEventsPublisher.value = .viewDidDisappear
    }
    
    // MARK: Setup view model
    
    private func setupViewModelOutput() {
        viewModelOutput.handleError = { [weak self] error in
            if error.shouldBlockUI {
                self?.showAlert(title: error.title ?? "", message: error.message)
            } else {
                self?.showToastMessage(message: error.message)
            }
        }
        
        viewModelOutput.centerMe = { [weak self] coordinate in
            self?.mapView.centerCoordinate = coordinate
        }
        
        viewModelOutput.updateUserLocationVisibility = { [weak self] isVisible in
            guard self?.mapView.showsUserLocation != isVisible else { return }

            self?.mapView.showsUserLocation = isVisible
        }
        
        viewModelOutput.showPinsOnMap = { [weak self] annotations in
            guard let self = self else { return }
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
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
        
        mapView.delegate = self
        
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        mapView.register(RestaurantAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    }
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is MKClusterAnnotation:
            return mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier, for: annotation)
        case is MKUserLocation:
            return nil
        default:
            return RestaurantAnnotationView(annotation: annotation, reuseIdentifier: "RestaurantID")
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        viewModelInput.onVisibleRegionChanged(
            regionCenter: mapView.region.center,
            latDelta: mapView.region.span.latitudeDelta,
            lngDelta: mapView.region.span.longitudeDelta
        )
    }
    
    // MARK: Alerts
    
    private func showToastMessage(message: String) {
        let font = UIFont.boldSystemFont(ofSize: 16)
        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.strokeColor: UIColor.white,
        ]
        
        view.showMessage(NSAttributedString(string: message, attributes: attributes), type: .error)
    }
    
    private func showAlert(title: String, message: String) {
        let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { [weak self] (action) in
            self?.viewModelInput.onSettingsAppOpeningRequest()
        }
        let okAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(openSettingsAction)
        alertController.addAction(okAction)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .left;

        let atrStr = NSMutableAttributedString(string: message, attributes: [
            NSAttributedString.Key.paragraphStyle : style,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)
        ])

        // Might lead to a rejection during Apple Review,
        // however it seems like all other major apps use it (Waze, MAPS.ME, etc)
        alertController.setValue(atrStr, forKey: "attributedMessage")
        
        present(alertController, animated: true, completion: nil)
    }
    
}

