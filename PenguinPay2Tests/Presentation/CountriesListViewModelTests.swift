//
//  CountriesListViewModelTests.swift
//  PenguinPay2Tests
//
//  Created by Matias Glessi on 25/03/2022.
//

import XCTest
import RxSwift

@testable import PenguinPay2

class CountriesListViewModelTests: XCTestCase {

    private let getCountriesService = GetCountriesServiceMock()
    private let disposeBag = DisposeBag()
    
    func test_onGetCountries_callsGetExchangeRateService() {
        let expectation = self.expectation(description: #function)
        let viewModel = makeSUT()
        
        getCountriesService.countryReturnValue = Country(id: "TZS", name: "Tanzania", flag: "🇹🇿", phonePrefix: "+255", numberOfDigitsAfterPrefix: 9)
    
        viewModel.items.subscribe(onNext :{ [weak self] countries in
            guard let self = self else {
                XCTFail()
                return
            }
            
            expectation.fulfill()
            XCTAssert(!countries.isEmpty)
            XCTAssert(self.getCountriesService.isGetCountriesListCalled())
        
        }).disposed(by: disposeBag)

        viewModel.getCountries()
        
        wait(for: [expectation], timeout: 2)
    }

    
    private func makeSUT() -> CountriesListViewModel {
        return CountriesListViewModel(getCountriesService: getCountriesService)
    }
}
