//
//  MapViewModel.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 05/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Combine

@frozen enum NoValue {
    case noValue
}

protocol ViewModelInput {
    var viewLifecyleEventsPublisher: CurrentValueSubject<ViewLifecycleEvent?, Never> { get }
}

open class ViewModel {
    let viewLifecyleEventsPublisher = CurrentValueSubject<ViewLifecycleEvent?, Never>(nil)
    
    // MARK: Shortcuts
    var viewDidAppearPublisher: AnyPublisher<NoValue, Never> {
        viewLifecyleEventsPublisher.compactMap { $0}.filter { $0 == .viewDidAppear }.map { _ in return NoValue.noValue }.eraseToAnyPublisher()
    }
    var viewDidDisappearPublisher: AnyPublisher<NoValue, Never> {
        viewLifecyleEventsPublisher.compactMap { $0}.filter { $0 == .viewDidDisappear }.map { _ in return NoValue.noValue }.eraseToAnyPublisher()
    }
    
    var appDidBecomeActive: AnyPublisher<NoValue, Never> {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).map { _ in return NoValue.noValue }.eraseToAnyPublisher()
    }
    
    var appWillResignActive: AnyPublisher<NoValue, Never> {
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification).map { _ in return NoValue.noValue }.eraseToAnyPublisher()
    }
}

final class MapViewModel: ViewModel, MapViewModelInput, MapViewModelOutput {
    struct Dependencies {
        let locationProvider: SimpleLocationProviding
    }
    
    struct Strings {
        static let cannotFetchGPSCoordinate = "Cannot fetch GPS coordinate"
        
        static let locationServicesAreDisabledTitle = "Location Services are disabled"
        static let locationServicesAreDisabledMessage = """
            Please turn Locations Services to benefit from more relevant search results:\n
            1. Open "Settings" app
            2. Go to "Privacy"
            3. Set "Location Services" to "While using the app"
        """
    }
    
    private let locationProvider: SimpleLocationProviding
    
    // MARK: Subscriptions tokens
    private var startMonitoringEventsToken: AnyCancellable?
    private var stopMonitoringEventsToken: AnyCancellable?
    private var centeringOnFirstAppearingToke: AnyCancellable?
    private var errorReportingOnAppearingToken: AnyCancellable?
    
    init(dependencies: Dependencies) {
        locationProvider = dependencies.locationProvider
        
        super.init()
        
        errorReportingOnAppearingToken = viewDidAppearPublisher.first().sink { [weak self] _ in
            guard let self = self else { return }
            guard self.locationProvider.isAuthorized else {
                self.handleError(.locationServicesNotAuthorized(
                                    title: Strings.locationServicesAreDisabledTitle,
                                    message: Strings.locationServicesAreDisabledMessage,
                                    shouldBlockUI: true))
                return
            }
        }
        
        centeringOnFirstAppearingToke = viewDidAppearPublisher.first().sink { [weak self] _ in
            guard let self = self else { return }
            
            self.locationProvider.fetchCurrentLocation { [weak self] (result) in
                switch result {
                case .success(let coordinate):
                    self?.centerMe(coordinate)
                case .failure(let error):
                    self?.handleError(.generic(title: nil, message: error.localizedDescription, shouldBlockUI: false))
                }
            }
            
            self.centeringOnFirstAppearingToke = nil
        }
        
        startMonitoringEventsToken = viewDidAppearPublisher.merge(with: appDidBecomeActive).sink { [weak self] _ in
            self?.locationProvider.startLocationUpdates()
        }
        
        stopMonitoringEventsToken = viewDidDisappearPublisher.merge(with: appWillResignActive).sink { [weak self] _ in
            self?.locationProvider.stopLocationUpdates()
        }
    }
    
    // ViewModelInput:
    func onCenteringRequest() {
        guard locationProvider.isAuthorized else {
            handleError(.locationServicesNotAuthorized(
                            title: Strings.locationServicesAreDisabledTitle,
                            message: Strings.locationServicesAreDisabledMessage,
                            shouldBlockUI: true))
            return
        }
        
        guard let coordinate = locationProvider.lastKnownGPSCoordinate else {
            handleError(.generic(title: nil,
                                 message: Strings.cannotFetchGPSCoordinate,
                                 shouldBlockUI: false))
            return
        }
        centerMe(coordinate)
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
