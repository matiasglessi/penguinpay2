//
//  ViewController.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 21/03/2022.
//

import UIKit
import RxSwift
import RxCocoa


class ViewController: UIViewController {

    @IBOutlet weak var textlabel: UILabel!
    private let disposeBag = DisposeBag()
    private var viewModel: ViewModel!


    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel(service: DefaultGetExchangeRateService(apiClient: URLSessionAPIClient()))
    }

    override func viewDidAppear(_ animated: Bool) {
        viewModel.exchange.observe(on: MainScheduler.instance ).subscribe { [weak self] exchange in
            self?.textlabel.text = String(exchange)
        }.disposed(by: disposeBag)
    }

    @IBAction func action(_ sender: Any) {
        viewModel.getExchange()
    }
}


class ViewModel {
    private let disposeBag = DisposeBag()
    public let exchange: PublishSubject<ExchangeRate> = PublishSubject()
    private let service: GetExchangeRateService
    
    init(service: GetExchangeRateService) {
        self.service = service
    }
    
    
    func getExchange() {
        service.execute(countryID: "NGN").subscribe { [weak self] exchangeRate in
            self?.exchange.onNext(exchangeRate)
        } onError: { error in
            print(error)
        }.disposed(by: disposeBag)
    }
}
