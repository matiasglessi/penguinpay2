//
//  URLSessionAPIClient.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 25/03/2022.
//

import RxSwift

enum APIClientError: Error, Equatable, CaseIterable {
    case missingData
    case invalidURL
    case invalidResponse
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
                        if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary,
                           let jsonData = convertedJsonIntoDict["rates"] as? [String : Any] {
                                observer.onNext(jsonData)
                                observer.onCompleted()
                            }
                        else {
                            observer.onError(APIClientError.invalidResponse)
                        }
                    } catch {
                        observer.onError(error)
                    }
                    
                    return Disposables.create()
                }
            }
    }
}
