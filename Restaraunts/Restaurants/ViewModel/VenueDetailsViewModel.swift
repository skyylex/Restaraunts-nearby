//
//  VenueDetailsViewModel.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import UIKit

final class VenueDetailsViewModel: ViewModel, VenueDetailsViewModelOutput, VenueDetailsViewModelInput {
    let venue: FourSquareVenue
    
    init(venue: FourSquareVenue) {
        self.venue = venue
    }
    
    // MARK: VenueDetailsViewModelOutput
    var showVenueImage: (UIImage) -> Void = { _ in fatalError("showVenueImage should be overriden by view") }
    
    
}
