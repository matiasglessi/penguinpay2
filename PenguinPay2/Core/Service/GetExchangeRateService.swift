//
//  GetExchangeRateService.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 24/03/2022.
//

import Foundation
import RxSwift

protocol GetExchangeRateService {
    func execute(countryID: String) -> Observable<ExchangeRate>
}
