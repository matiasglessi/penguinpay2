//
//  APIClientTests.swift
//  PenguinPay2Tests
//
//  Created by Matias Glessi on 25/03/2022.
//

import XCTest
import RxSwift
import RxTest

@testable import PenguinPay2

class APIClientTests: XCTestCase {

    private let session = SessionMock()
    private let fakeURL = URL(string: "http://fake.url.com")
    private let missingDataError = APIClientError.missingData

    func test_whenSessionHasDataAndNoError_ThenTheJSONIsRetrieved() {
        let countryID = "NGN"
        let jsonDataExpected: [String : Any] = [ "rates" : [ countryID : 430.69 ] ]
        session.data = jsonToData(with: jsonDataExpected)
        let apiClient = makeSUT()
        
        if let jsonDataResult = try? apiClient.get(from: fakeURL).toBlocking().first(),
           let ratesJSON = jsonDataExpected["rates"] as? [String : Any] {
            XCTAssertEqual(jsonDataResult[countryID] as? ExchangeRate, ratesJSON[countryID] as? ExchangeRate)
        }
        else { XCTFail() }
    }
    
    func test_whenSessionHasNoData_thenNoResultIsRetrieved() {
        let apiClient = makeSUT()
        let jsonDataResult = try? apiClient.get(from: fakeURL).toBlocking().first()
        XCTAssertNil(jsonDataResult)
    }
    
    func jsonToData(with json: [String: Any]) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            return nil
        }
    }
    
    private func makeSUT() -> APIClient {
        return URLSessionAPIClient(session: session)
    }
}
