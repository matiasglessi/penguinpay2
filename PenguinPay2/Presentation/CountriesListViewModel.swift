//
//  CountriesListViewModel.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 24/03/2022.
//

import Foundation
import RxSwift

class CountriesListViewModel {
    private let getCountriesService: GetCountriesService
    private let disposeBag = DisposeBag()

    let items = PublishSubject<[Country]>()

    init(getCountriesService: GetCountriesService) {
        self.getCountriesService = getCountriesService
    }

    func getCountries() {
        getCountriesService.getCountries().bind(to: items).disposed(by: disposeBag)
    }
}
