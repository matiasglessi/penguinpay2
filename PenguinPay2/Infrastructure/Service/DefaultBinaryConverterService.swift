//
//  DefaultBinaryConverterService.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 25/03/2022.
//

import Foundation
import RxSwift

class DefaultBinaryConverterService: BinaryConverterService {
    func toBinary(decimal: Double) -> Observable<String> {
        Observable<String>.create { [weak self] observer in
            
            guard let self = self else { return Disposables.create() }
            
            let split = String(decimal).components(separatedBy: ".")
            let beforeDecimalIntValue = Int(split[0])

            if self.onlyHasWholePart(split) {
                observer.onNext( self.toBinary(int: beforeDecimalIntValue))
            }
            else {
                let afterDecimalDoubleValue = Double("0." + split[1])
                
                let a = self.toBinary(int: beforeDecimalIntValue)
                    let b = self.afterDecimal(double: afterDecimalDoubleValue)
                
                observer.onNext(
                    a
                        + "."
                        + b
                )
            }

            return Disposables.create()
        }
    }
    
    func toDecimal(binary: String) -> Observable<Double> {
        Observable<Double>.create { [weak self] observer in
            
            guard let self = self else { return Disposables.create() }
            
            let split = binary.components(separatedBy: ".")
            
            if self.onlyHasWholePart(split) {
                observer.onNext(self.beforeDecimal(string: split[0]))
            }
            else {
                observer.onNext(
                    self.beforeDecimal(string: split[0])
                        + self.afterDecimal(string: split[1])
                )
            }

            return Disposables.create()
        }
    }
    
    
    // MARK: Helper methods
    
    private func onlyHasWholePart(_ split: [String]) -> Bool {
        split.count == 1
    }
    
    private func toBinary(int: Int?) -> String {
        guard let int = int else { return "0" }
        return String(int, radix:2)
    }
    
    private func afterDecimal(double: Double?) -> String {
        
        guard var value = double,
              value != 0 else { return "0" }
        
        var finalValue = ""
        while value != 1 {
            value *= 2
            finalValue = finalValue + String(Int(value))
            if value > 1 {
                value = value - Double(Int(value))
            }
        }
        
        return finalValue
    }
    
    private func beforeDecimal(string: String) -> Double {
        var value: Double = 0.0
        
        for (index, element) in string.reversed().enumerated() {
            let multiplication = pow(Double(2), Double(index))
            if let charToDouble = Double(String(element)) {
                value += multiplication * charToDouble
            }
        }
        return value
    }
    
    private func afterDecimal(string: String) -> Double {
        var value: Double = 0.0
        
        for (index, element) in string.enumerated() {
            let multiplication = pow((1/Double(2)), Double(index + 1))
            if let charToDouble = Double(String(element)) {
                value += multiplication * charToDouble
            }
        }
        return value
    }
}

