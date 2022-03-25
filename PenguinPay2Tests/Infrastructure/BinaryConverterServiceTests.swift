//
//  BinaryConverterServiceTests.swift
//  PenguinPay2Tests
//
//  Created by Matias Glessi on 25/03/2022.
//

import XCTest
import RxBlocking
import RxTest
import RxSwift
@testable import PenguinPay2

class BinaryConverterServiceTests: XCTestCase {
    
    func test_onServiceCallWithBinary010110_returnsDecimal22() {
        let binaryValue = "10110.0"
        let expectedDecimalResult: Double = 22.0
        
        let binaryService = DefaultBinaryConverterService()
        let decimalValue = try? binaryService.toDecimal(binary: binaryValue).toBlocking().first()
        XCTAssertEqual(decimalValue, expectedDecimalResult)
    }
    
    func test_onServiceCallWithDecimal22_returnsBinary010110() {
        let expectedBinaryResult = "10110.0"
        let decimalValue: Double = 22.0
        
        let binaryService = DefaultBinaryConverterService()
        let binaryValue = try? binaryService.toBinary(decimal: decimalValue).toBlocking().first()
        XCTAssertEqual(binaryValue, expectedBinaryResult)
    }
}
