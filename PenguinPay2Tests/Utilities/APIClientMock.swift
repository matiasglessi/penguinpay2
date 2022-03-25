//
//  APIClientMock.swift
//  PenguinPay2Tests
//
//  Created by Matias Glessi on 25/03/2022.
//

import RxSwift
@testable import PenguinPay2

class APIClientMock: APIClient {
    
    var apiClientReturnValue: [String : Any]?
    private var isServiceCalled = false

    func get(from url: URL?) -> Observable<[String : Any]> {
        Observable<[String : Any]>.create { [weak self] observer in
            self?.isServiceCalled = true
            observer.onNext(self?.apiClientReturnValue ?? [:])
            return Disposables.create()
        }
    }
    
    func isGetCountryCalled() -> Bool {
        return isServiceCalled
    }
}
