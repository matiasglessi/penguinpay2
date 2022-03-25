//
//  GetExchangeRateServiceTests.swift
//  PenguinPay2Tests
//
//  Created by Matias Glessi on 25/03/2022.
//

import XCTest
import RxSwift

@testable import PenguinPay2

class GetExchangeRateServiceTests: XCTestCase {
    
    private let apiClient = APIClientMock()
    
    func test_onServiceExecutionWithCountryID_serviceReturnsSuccessResultOfExchangeRate() {
        let service = makeSUT()
        let countryID = "NGN"
        let expectedExchangeRate: ExchangeRate = 430.6
        apiClient.apiClientReturnValue = [countryID: expectedExchangeRate]
        
        let result = try? service.execute(countryID: countryID).toBlocking().first()
        XCTAssertEqual(result, expectedExchangeRate)
    }
    
    private func makeSUT() -> GetExchangeRateService {
        return DefaultGetExchangeRateService(apiClient: apiClient)
    }
}
