//
//  BinaryConverterServiceMock.swift
//  PenguinPay2Tests
//
//  Created by Matias Glessi on 25/03/2022.
//

import RxSwift
@testable import PenguinPay2

class BinaryConverterServiceMock: BinaryConverterService {
        
    private var isToBinaryServiceCalled = false
    private var isToDecimalServiceCalled = false

    var binaryReturnValue: String?

    func toBinary(decimal: Double) -> Observable<String> {
        Observable<String>.create { [weak self] observer in
            
            guard let self = self else { return Disposables.create() }
            
            self.isToBinaryServiceCalled = true

            observer.onNext(self.binaryReturnValue ?? "0")


            return Disposables.create()
        }
    }
    
    func toDecimal(binary: String) -> Observable<Double> {
        Observable<Double>.create { [weak self] observer in
            
            guard let self = self else { return Disposables.create() }
            self.isToDecimalServiceCalled = true

            observer.onNext(10.0)

            return Disposables.create()
        }

    }
    

    func isToBinaryCalled() -> Bool {
        return isToBinaryServiceCalled
    }

    func isToDecimalCalled() -> Bool {
        return isToDecimalServiceCalled
    }

}
