//
//  RootCoordinator.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 05/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import UIKit

/// Initiates application UX flow
final class RootCoordinator {
    
    /// Starts UX Flow with Map screen
    /// - Parameter window: UIWindow to render Map
    func start(with window: UIWindow) {
        let dependencies = MapViewModel.Dependencies(
            locationProvider: SimpleLocationProvider(),
            searchService: FourSquareService()
        )
        let mapViewModel = MapViewModel(dependencies: dependencies)
        let rootViewController = MapViewController()
        rootViewController.viewModelInput = mapViewModel
        rootViewController.viewModelOutput = mapViewModel
        
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
    
}
