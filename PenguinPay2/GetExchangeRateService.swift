//
//  GetExchangeRateService.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 21/03/2022.
//

import Foundation
import RxSwift

typealias ExchangeRate = Double

protocol GetExchangeRateService {
    func execute(countryID: String) -> Observable<ExchangeRate>
}

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


protocol APIClient {
    func get(from url: URL?) -> Observable<[String : Any]>
}

enum APIClientError: Error, Equatable, CaseIterable {
    case missingData
    case invalidURL
    case unknown
}


class URLSessionAPIClient: APIClient {
    
    private let session: Session
    private let disposeBag = DisposeBag()

    init(session: Session = URLSession.shared) {
        self.session = session
    }
    
    func get(from url: URL?) -> Observable<[String : Any]> {
        
        guard let url = url else {
            return Observable.error(APIClientError.invalidURL)
        }
        
        return session.loadData(from: url)
            .flatMap { data, response, error -> Observable<[String:Any]> in
                return .create { observer -> Disposable in
                    
                    if let error = error {
                        observer.onError(error)
                        return Disposables.create()
                    }
                    
                    guard let data = data else {
                        observer.onError(APIClientError.missingData)
                        return Disposables.create()
                    }
                    
                    do {
                        if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                            if let jsonData = convertedJsonIntoDict["rates"] as? [String : Any] {
                                observer.onNext(jsonData)
                                observer.onCompleted()
                            }
                        }
                    } catch {
                        observer.onError(error)
                    }
                    
                    return Disposables.create()
                }
            }
    }
}
