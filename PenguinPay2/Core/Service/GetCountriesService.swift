//
//  GetCountriesService.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 24/03/2022.
//

import RxSwift

protocol GetCountriesService {
    func getCountry(from countryID: String) -> Observable<Country>
    func getCountries() -> Observable<[Country]>
}
