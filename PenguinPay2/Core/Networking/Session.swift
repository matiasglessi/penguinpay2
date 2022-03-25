//
//  Session.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 24/03/2022.
//

import Foundation
import RxSwift

protocol Session {
    func loadData(from url: URL) -> Observable<(Data?, URLResponse?, Error?)>
}

extension URLSession: Session {
    func loadData(from url: URL) -> Observable<(Data?, URLResponse?, Error?)> {
        
        return Observable<(Data?, URLResponse?, Error?)>.create { [weak self] observable in
            
            guard let strongSelf = self else { return Disposables.create() }
            
            let task = strongSelf.dataTask(with: url) { data, response, error in
                observable.onNext((data, response, error))
                observable.onCompleted()
            }
            
            task.resume()

            return Disposables.create { task.cancel() }
        }
    }
}
