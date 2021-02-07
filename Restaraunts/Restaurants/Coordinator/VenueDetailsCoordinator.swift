//
//  VenueDetailsCoordinator.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import UIKit

final class VenueDetailsCoordinator: Coordinator {
    func start(with venue: FourSquareVenue, currentVC: UIViewController) {
        let venueDetailsVC = VenueDetailsViewController()
        let venueViewModel = VenueDetailsViewModel(venue: venue)
        
        venueDetailsVC.viewModelInput = venueViewModel
        venueDetailsVC.viewModelOutput = venueViewModel
        
        venueDetailsVC.attach(coordinator: self)
        
        currentVC.present(venueDetailsVC, animated: true, completion: nil)
    }
}
