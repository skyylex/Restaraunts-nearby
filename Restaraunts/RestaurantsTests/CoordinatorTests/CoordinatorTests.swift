//
//  CoordinatorTests.swift
//  RestaurantsTests
//
//  Created by Yury Lapitsky on 08/02/2021.
//  Copyright © 2021 Yury Lapitsky. All rights reserved.
//

import Foundation
import XCTest
@testable import Restaurants

final class CoordinatorTests: XCTestCase {
    
    func testAddChild() {
        let parent = Coordinator()
        let child = Coordinator()
        
        XCTAssertEqual(parent.children.count, 0)
        XCTAssertNil(child.parent)
        
        parent.addChild(child)
        
        XCTAssertTrue(parent.children.contains { $0 === child } )
        XCTAssertEqual(parent.children.count, 1)
        XCTAssertTrue(child.parent === parent)
    }
    
    func testRemoveChild() {
        let parent = Coordinator()
        let child = Coordinator()
        
        parent.addChild(child)
        parent.removeChild(child)
        
        XCTAssertEqual(parent.children.count, 0)
        XCTAssertNil(child.parent)
    }
    
    func testAttachToVC() {
        let parent = Coordinator()
        var child: Coordinator? = Coordinator()
        var vc: UIViewController? = UIViewController()
        
        parent.addChild(child!)
        
        // Simulating deinit in ViewController to trigger removal from child
        vc?.attach(coordinator: child!)
        vc = nil
        
        weak var weakChild: Coordinator? = child
        child = nil // should be the last retaining reference
        
        XCTAssertNil(weakChild)
        XCTAssertEqual(parent.children.count, 0)
    }
    
}
