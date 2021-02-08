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

/// Initiates application UX flow
final class MapViewCoordinator: Coordinator {
    
    /// Starts UX Flow with Map screen
    /// - Parameter window: UIWindow to render Map
    func start(with window: UIWindow) {
        let rootViewController = MapViewController()
        
        let config = FourSquareConfig()
        let api = FoursquareAPIClient(clientId: config.clientId, clientSecret: config.clientSecret)
        
        let showVenueDetailsCallback: (FourSquareVenue) -> Void = { [weak self] venue in
            guard let self = self else { return }
            
            let detailsCoordinator = VenueDetailsViewCoordinator()
            self.addChild(detailsCoordinator)
            detailsCoordinator.start(with: venue, currentVC: rootViewController)
        }
        
        let openSettingsAppCallback = {
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        let dependencies = MapViewModel.Dependencies(
            locationProvider: SimpleLocationProvider(),
            searchService: FourSquareService(apiClient: api),
            showVenueDetailsCallback: showVenueDetailsCallback, openSettingsApp: openSettingsAppCallback
        )
        let mapViewModel = MapViewModel(dependencies: dependencies)
        rootViewController.viewModelInput = mapViewModel
        rootViewController.viewModelOutput = mapViewModel
        
        // No rootViewController.attach(rootCoordinator) here,
        // due to different retaining strategy for RootCoordinator
        
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }
}
