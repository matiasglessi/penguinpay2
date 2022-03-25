//
//  SessionMock.swift
//  PenguinPay2Tests
//
//  Created by Matias Glessi on 25/03/2022.
//

import RxSwift
@testable import PenguinPay2

class SessionMock: Session {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    func loadData(from url: URL) -> Observable<(Data?, URLResponse?, Error?)> {
        Observable<(Data?, URLResponse?, Error?)>.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            observer.onNext((self.data, self.response, self.error))
            return Disposables.create()
        }
    }
}
