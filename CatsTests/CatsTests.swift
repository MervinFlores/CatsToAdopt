//
//  CatsTests.swift
//  CatsTests
//
//  Created by Mervin Flores on 3/8/24.
//

import XCTest
@testable import Cats

class CatDetailControllerTests: XCTestCase {
    var sut: CatDetailController!
    
    override func setUp() {
        super.setUp()
        sut = CatDetailController()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testPrepareTitleText_WithValidOwner_ShouldReturnNewOwner() {
        // Given
        let owner = "John Doe"
        
        // When
        let result = sut.prepareTitleText(owner: owner)
        
        // Then
        XCTAssertEqual(result, "New Owner: \(owner)")
    }
    
    func testPrepareTitleText_WithNilOwner_ShouldReturnAvailableToAdopt() {
        // Given
        let owner: String? = nil
        
        // When
        let result = sut.prepareTitleText(owner: owner)
        
        // Then
        XCTAssertEqual(result, "availableToAdopt".localized)
    }
    
    func testPrepareDateText_WithValidOwner_ShouldReturnAdopted() {
        // Given
        let owner = "John Doe"
        let date = Date()
        
        // When
        let result = sut.prepareDateText(owner: owner, date: date)
        
        // Then
        XCTAssertTrue(result.contains("Adopted:"))
    }
    
    func testPrepareDateText_WithNilOwner_ShouldReturnLastUpdate() {
        // Given
        let owner: String? = nil
        let date = Date()
        
        // When
        let result = sut.prepareDateText(owner: owner, date: date)
        
        // Then
        XCTAssertTrue(result.contains("Last Update:"))
    }
    

}
