//
//  GetExchangeRateServiceMock.swift
//  PenguinPay2Tests
//
//  Created by Matias Glessi on 25/03/2022.
//

import RxSwift
@testable import PenguinPay2

class GetExchangeRateServiceMock: GetExchangeRateService {
    
    private var isServiceCalled = false
    var exchangeRateReturnValue: ExchangeRate?

    func execute(countryID: String) -> Observable<ExchangeRate> {
        Observable<ExchangeRate>.create { [weak self] observer in
            self?.isServiceCalled = true
            observer.onNext(self?.exchangeRateReturnValue ?? 0.0)
            return Disposables.create()
        }
    }
    
    func isCalled() -> Bool {
        return isServiceCalled
    }
}
