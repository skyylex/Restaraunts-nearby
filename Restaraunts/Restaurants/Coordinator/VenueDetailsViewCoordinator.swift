//
//  VenueDetailsViewCoordinator.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import UIKit
import FoursquareAPIClient

final class VenueDetailsViewCoordinator: Coordinator {
    func start(with venue: FourSquareVenue, currentVC: UIViewController) {
        let venueDetailsVC = VenueDetailsViewController()
        let config = FourSquareConfig()
        let apiClient = FoursquareAPIClient(clientId: config.clientId, clientSecret: config.clientSecret)
        let venueViewModel = VenueDetailsViewModel(
            venue: venue,
            fourSquareService: FourSquareService(apiClient: apiClient)
        )
        
        venueDetailsVC.viewModelInput = venueViewModel
        venueDetailsVC.viewModelOutput = venueViewModel
        
        venueDetailsVC.attach(coordinator: self)
        
        currentVC.present(venueDetailsVC, animated: true, completion: nil)
    }
    
}
