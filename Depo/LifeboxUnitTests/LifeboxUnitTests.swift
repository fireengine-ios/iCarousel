//
//  LifeboxUnitTests.swift
//  LifeboxUnitTests
//
//  Created by Bondar Yaroslav on 9/14/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import XCTest
@testable import lifebox

class LifeboxUnitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAutologinURL() {
        /// Given
        let urlString = "http://adepo.turkcell.com.tr/api/auth/gsm/login?rememberMe=on" /// prod url
        let url = URL(string: urlString)!
        let params = Authentication3G()
        
        /// When
        let paramsUrl = params.patch
        
        /// Then
        XCTAssertTrue(paramsUrl == url)
    }
}
