//
//  VenueDetailsViewController.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 07/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import BottomPopup

protocol VenueDetailsViewModelInput: ViewModelInput {
    
}

protocol VenueDetailsViewModelOutput {
    var showVenueImage: (UIImage) -> Void { get set }
}

final class VenueDetailsViewController: BottomPopupViewController {
    var viewModelInput: VenueDetailsViewModelInput!
    var viewModelOutput: VenueDetailsViewModelOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        attachImage()
        
        viewModelInput.viewLifecyleEventsPublisher.value = .viewDidLoad
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModelInput.viewLifecyleEventsPublisher.value = .viewDidAppear
    }
    
    // MARK: Views
    
    private let imageView = UIImageView()
    
    private func setupView() {
        view.backgroundColor = .almostWhite
    }
    
    private func attachImage() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        let constraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
