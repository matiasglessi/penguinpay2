//
//  GetCountriesServiceMock.swift
//  PenguinPay2Tests
//
//  Created by Matias Glessi on 25/03/2022.
//

import RxSwift
@testable import PenguinPay2

class GetCountriesServiceMock: GetCountriesService {
    
    private var isGetCountryServiceCalled = false
    private var isGetCountriesListServiceCalled = false
    var countryReturnValue: Country?

    func getCountry(from countryID: String) -> Observable<Country> {
        Observable<Country>.create { [weak self] observer in
            self?.isGetCountryServiceCalled = true
            observer.onNext(self?.countryReturnValue ??
                Country(id: "ARG", name: "Argentina", flag: "🇦🇷", phonePrefix: "+549", numberOfDigitsAfterPrefix: 10)
            )
            return Disposables.create()
        }
    }
    
    func getCountries() -> Observable<[Country]> {
        Observable<[Country]>.create { [weak self] observer in
            self?.isGetCountriesListServiceCalled = true
            observer.onNext([
                self?.countryReturnValue ??
                    Country(id: "ARG", name: "Argentina", flag: "🇦🇷", phonePrefix: "+549", numberOfDigitsAfterPrefix: 10)
            ])
            return Disposables.create()
        }
    }

    func isGetCountryCalled() -> Bool {
        return isGetCountryServiceCalled
    }

    func isGetCountriesListCalled() -> Bool {
        return isGetCountriesListServiceCalled
    }
}
