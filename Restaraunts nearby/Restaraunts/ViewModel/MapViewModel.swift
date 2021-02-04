//
//  MapViewModel.swift
//  Restaraunts
//
//  Created by Yury Lapitsky on 05/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import SwiftLocation
import UIKit
import CoreLocation

final class MapViewModel: MapViewModelInput, MapViewModelOutput {
    static let defaultMessage = "Unknown error happened while fetching current user location"
    
    // ViewModelInput:
    func onCenteringRequest() {
        guard let coordinate = SwiftLocation.lastKnownGPSLocation?.coordinate else {
            // TODO: improve handling here
            return
        }
        
        centerMe(coordinate)
    }
    
    func onViewDidAppear() {
        SwiftLocation.gpsLocationWith({ (options) in
            options.subscription = .single
        }).then { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.centerMe(data.coordinate)
            case .failure(let error):
                self?.handleError(.generic(message: error.failureReason ?? Self.defaultMessage))
            }
        }

        SwiftLocation.gpsLocationWith({ (options) in
            options.subscription = .continous
        }).then { _ in
            // Continue getting updates to have a fast re-centering over user location
        }
    }
    
    func onSettingsAppOpeningRequest() {
        // TODO: move to Coordinator
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // ViewModelOutput:
    var handleError: (MapViewError) -> Void = {_ in preconditionFailure("handleError: should be overriden by MapView") }
    var centerMe: (CLLocationCoordinate2D) -> Void = { _ in preconditionFailure("centerMe: should be overriden by MapView") }
    
}
