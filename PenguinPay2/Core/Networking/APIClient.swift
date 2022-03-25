//
//  APIClient.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 24/03/2022.
//

import Foundation
import RxSwift

protocol APIClient {
    func get(from url: URL?) -> Observable<[String : Any]>
}

