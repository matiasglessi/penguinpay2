//
//  DefaultGetCountriesService.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 25/03/2022.
//

import RxSwift

class DefaultGetCountriesService: GetCountriesService {
    
    private let countries = [
        Country(id: "KES", name: "Kenya", flag: "🇰🇪", phonePrefix: "+254", numberOfDigitsAfterPrefix: 9),
        Country(id: "NGN", name: "Nigeria", flag: "🇳🇬", phonePrefix: "+234", numberOfDigitsAfterPrefix: 7),
        Country(id: "TZS", name: "Tanzania", flag: "🇹🇿", phonePrefix: "+255", numberOfDigitsAfterPrefix: 9),
        Country(id: "UGX", name: "Uganda", flag: "🇺🇬", phonePrefix: "+256", numberOfDigitsAfterPrefix: 7)
    ]
    
    func getCountry(from countryID: String) -> Observable<Country> {
        Observable<Country>.create { [weak self] observer in
            guard let self = self,
                  let country = self.countries.filter({ $0.id == countryID }).first
            else { return Disposables.create() }
            
            observer.onNext(country)

            return Disposables.create()
        }
    }
    
    func getCountries() -> Observable<[Country]> {
        Observable<[Country]>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            observer.onNext(self.countries)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}
