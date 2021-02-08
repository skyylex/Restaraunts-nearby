//
//  Coordinator.swift
//  Restaurants
//
//  Created by Yury Lapitsky on 08/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import UIKit

/// Base coordinator that  enables Coordinator hierarchy
class Coordinator {
    private (set) var children = [Coordinator]()
    weak var parent: Coordinator?
    
    func addChild(_ coordinator: Coordinator) {
        coordinator.parent = self
        children += [coordinator]
    }
    
    func removeChild(_ coordinator: Coordinator) {
        children = children.filter { $0 !== coordinator }
        coordinator.parent = nil
    }
    
    func removeFromParent() {
        parent?.removeChild(self)
    }
    
}

extension UIViewController {
    func attach(coordinator: Coordinator) {
        deinitCallback = { [weak coordinator] in
            coordinator?.removeFromParent()
        }
    }
    
    private static var DeinitCallbackKey: UInt8 = 0

    private class DeinitCallbackWrapper {
        let callback: DeinitCallback
        
        init(callback: @escaping DeinitCallback) {
            self.callback = callback
        }
        
        deinit {
            callback()
        }
    }
    
    private typealias DeinitCallback = () -> Void
    
    private var deinitCallback: DeinitCallback {
        get {
            let callbackWrapper = objc_getAssociatedObject(self, &UIViewController.DeinitCallbackKey) as! DeinitCallbackWrapper
            return callbackWrapper.callback
        }
        set {
            let wrapper = DeinitCallbackWrapper(callback: newValue)
            objc_setAssociatedObject(self, &UIViewController.DeinitCallbackKey, wrapper, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
