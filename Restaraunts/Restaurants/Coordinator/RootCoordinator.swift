//
//  RootCoordinator.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 05/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import UIKit
import FoursquareAPIClient
import CombineCocoa

class Coordinator {
    private (set) var children = [Coordinator]()
    weak var parent: Coordinator?
    
    func addChild(_ coordinator: Coordinator) {
        children += [coordinator]
    }
    
    func removeChild(_ coordinator: Coordinator) {
        children = children.filter { $0 === coordinator }
    }
    
    func removeFromParent() {
        parent?.removeChild(self)
    }
}

extension UIViewController {
    func attach(coordinator: Coordinator) {
        deinitCallback = { [weak coordinator] in
            coordinator?.removeFromParent()
        }
    }
    
    private static var DeinitCallbackKey: UInt8 = 0

    private class DeinitCallbackWrapper {
        let callback: DeinitCallback
        
        init(callback: @escaping DeinitCallback) {
            self.callback = callback
        }
        
        deinit {
            callback()
        }
    }
    
    private typealias DeinitCallback = () -> Void
    
    private var deinitCallback: DeinitCallback {
        get {
            let callbackWrapper = objc_getAssociatedObject(self, &UIViewController.DeinitCallbackKey) as! DeinitCallbackWrapper
            return callbackWrapper.callback
        }
        set {
            let wrapper = DeinitCallbackWrapper(callback: newValue)
            objc_setAssociatedObject(self, &UIViewController.DeinitCallbackKey, wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/// Initiates application UX flow
final class RootCoordinator: Coordinator {
    
    /// Starts UX Flow with Map screen
    /// - Parameter window: UIWindow to render Map
    func start(with window: UIWindow) {
        let rootViewController = MapViewController()
        
        let config = FourSquareConfig()
        let api = FoursquareAPIClient(clientId: config.clientId, clientSecret: config.clientSecret)
        let dependencies = MapViewModel.Dependencies(
            locationProvider: SimpleLocationProvider(),
            searchService: FourSquareService(apiClient: api),
            showVenueDetailsCallback: { [weak self] venue in
                guard let self = self else { return }
                self.showVenueDetails(venue, currentViewController: rootViewController)
            }
        )
        let mapViewModel = MapViewModel(dependencies: dependencies)
        rootViewController.viewModelInput = mapViewModel
        rootViewController.viewModelOutput = mapViewModel
        
        // No rootViewController.attach(rootCoordinator) here,
        // due to different retaining strategy for RootCoordinator
        
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    // External
    private func showVenueDetails(_ venue: FourSquareVenue, currentViewController: UIViewController) {
        let detailsCoordinator = VenueDetailsCoordinator()
        addChild(self)
        detailsCoordinator.start(with: venue, currentVC: currentViewController)
    }
}
