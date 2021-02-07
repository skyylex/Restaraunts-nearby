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
    var showVenueImage: (UIImage?) -> Void { get set }
    var startSpinner: () -> Void { get set }
    var stopSpinner: () -> Void { get set }
}

final class VenueDetailsViewController: BottomPopupViewController {
    var viewModelInput: VenueDetailsViewModelInput!
    var viewModelOutput: VenueDetailsViewModelOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        attachImage()
        attachActivityIndicator()
        attachImageNotLoadedLabel()
        setupViewModelOutput()
        
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
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private func attachActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        imageView.addSubview(activityIndicator)
        
        activityIndicator.color = .almostWhite
        
        let constraints = [
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private let imageNotLoadedLabel = UILabel()
    
    private func attachImageNotLoadedLabel() {
        imageNotLoadedLabel.textAlignment = .center
        imageNotLoadedLabel.textColor = .almostWhite
        imageNotLoadedLabel.text = "Cannot find image for this venue"
        imageNotLoadedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.addSubview(imageNotLoadedLabel)
        
        let constraints = [
            imageNotLoadedLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: 20),
            imageNotLoadedLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            imageNotLoadedLabel.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        imageNotLoadedLabel.isHidden = true
    }
    
    private func attachImage() {
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 5.0
        
        view.addSubview(imageView)
        
        let constraints = [
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: ViewModel
    
    private func setupViewModelOutput() {
        viewModelOutput.showVenueImage = { [weak self] image in
            if let image = image {
                self?.imageView.image = image
            } else {
                self?.imageNotLoadedLabel.isHidden = false
            }
        }
        
        viewModelOutput.startSpinner = { [weak self] in
            self?.activityIndicator.startAnimating()
        }
        
        viewModelOutput.stopSpinner = { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
}
