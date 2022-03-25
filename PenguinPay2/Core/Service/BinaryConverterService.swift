//
//  BinaryConverterService.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 24/03/2022.
//

import Foundation
import RxSwift

protocol BinaryConverterService {
    func toBinary(decimal: Double) -> Observable<String>
    func toDecimal(binary: String) -> Observable<Double>
}
