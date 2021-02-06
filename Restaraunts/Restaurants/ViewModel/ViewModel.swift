//
//  ViewModel.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 06/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import Combine
import UIKit

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
