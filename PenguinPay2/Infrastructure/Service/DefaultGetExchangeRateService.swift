//
//  DefaultGetExchangeRateService.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 25/03/2022.
//

import RxSwift

class DefaultGetExchangeRateService: GetExchangeRateService {
    private let apiClient: APIClient
    private let baseURL = "https://openexchangerates.org/api/latest.json?app_id=0579c709c4aa411b99d80e302280f1b2&symbols="
    private let disposeBag = DisposeBag()
    
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func execute(countryID: String) -> Observable<ExchangeRate> {
        return apiClient.get(from: URL(string: baseURL + countryID))
            .flatMap { jsonData -> Observable<ExchangeRate> in
                return .create { observer -> Disposable in
                    if let rate = jsonData[countryID] as? ExchangeRate {
                        observer.onNext(rate)
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
    }
}
