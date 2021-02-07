//
//  VenueDetailsViewModel.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import UIKit
import Combine

final class VenueDetailsViewModel: ViewModel, VenueDetailsViewModelOutput, VenueDetailsViewModelInput {
    private let venue: FourSquareVenue
    private var photosFetchToken: AnyCancellable?
    private var startLoadingSpinnerToken: AnyCancellable?
    
    init(venue: FourSquareVenue, fourSquareService: FourSquareServicing) {
        self.venue = venue
        
        super.init()
        
        startLoadingSpinnerToken = viewDidLoadPublisher.sink { [weak self] result in
            self?.startSpinner()
            self?.startLoadingSpinnerToken = nil
        }
        
        let photoResultsPublisher = fourSquareService.fetchPhoto(with: venue.id).eraseToAnyPublisher()
        photosFetchToken = photoResultsPublisher.zip(viewDidAppearPublisher.first())
                                                .receive(on: DispatchQueue.global())
                                                .sink { [weak self] (photoItem, NoValue) in
                                                    guard let self = self else { return }
            
                                                    var image: UIImage?
                                                    if let url = photoItem?.url(), let data = try? Data(contentsOf: url) {
                                                        image = UIImage(data: data)
                                                    }
            
                                                    DispatchQueue.main.async { [weak self] in
                                                        self?.stopSpinner()
                                                        self?.showVenueImage(image)
                                                    }
                                                                                            
                                                    self.photosFetchToken = nil
        }
    }
    
    // MARK: VenueDetailsViewModelOutput
    var showVenueImage: (UIImage?) -> Void = { _ in fatalError("showVenueImage should be overriden by view") }
    var startSpinner: () -> Void = { fatalError("startSpinner should be overriden by view") }
    var stopSpinner: () -> Void = { fatalError("stopSpinner should be overriden by view") }
    
}
