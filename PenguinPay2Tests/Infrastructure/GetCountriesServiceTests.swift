//
//  GetCountriesServiceTests.swift
//  PenguinPay2Tests
//
//  Created by Matias Glessi on 25/03/2022.
//

import XCTest
import RxBlocking
import RxTest
import RxSwift
@testable import PenguinPay2

class GetCountriesServiceTests: XCTestCase {
    
    func test_onServiceCall_returnsCountries() {
        let getCountryService = DefaultGetCountriesService()
        
        if let countries = try? getCountryService.getCountries().toBlocking().first() {
            XCTAssert(!countries.isEmpty)
        }
        else { XCTFail() }
    }
    
    func test_onServiceCallWithCountryCode_returnsCountry() {
        
        let expectedCountryID = "NGN"
        
        let getCountryService = DefaultGetCountriesService()
        let country = try? getCountryService.getCountry(from: expectedCountryID).toBlocking().first()
        XCTAssertEqual(country?.id, expectedCountryID)
    }

}
