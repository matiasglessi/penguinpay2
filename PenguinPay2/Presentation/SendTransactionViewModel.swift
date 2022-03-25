//
//  SendTransactionViewModel.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 24/03/2022.
//

import RxSwift

class SendTransactionViewModel {
    private let disposeBag = DisposeBag()
    public let exchangeRate: PublishSubject<ExchangeRate> = PublishSubject()
    public let transactionValidation: PublishSubject<Bool> = PublishSubject()
    public let transactionMessage: PublishSubject<String> = PublishSubject()

    private let transactionInformation: PublishSubject<(Bool, String, String, ExchangeRate, String)> = PublishSubject()
    
    private let getExchangeService: GetExchangeRateService
    private let getCountriesService: GetCountriesService
    private let binaryConverterService: BinaryConverterService

    private var selectedExchangeRate: ExchangeRate?
    
    init(getExchangeService: GetExchangeRateService, getCountriesService: GetCountriesService, binaryConverterService: BinaryConverterService) {
        self.getExchangeService = getExchangeService
        self.getCountriesService = getCountriesService
        self.binaryConverterService = binaryConverterService
        
        transactionInformation
            .subscribe(onNext: { [weak self] isValidTransaction, recipientName, countryID, exchangeRate, amount in
                isValidTransaction ?
                    self?.getTransactionMessage(recipient: recipientName, country: countryID, exchangeRate: exchangeRate, amount: amount) :
                    self?.transactionMessage.onNext("Something is wrong. Please review the entered information.")
        }).disposed(by: disposeBag)
    }
    
    func getExchangeRate(for countryID: String) {
        getExchangeService.execute(countryID: countryID).subscribe(onNext :{ [weak self] exchangeRate in
            self?.selectedExchangeRate = exchangeRate
            self?.exchangeRate.onNext(exchangeRate)
        }).disposed(by: disposeBag)
    }
    
    func validateTransactionInformation(fullNameText: String, countryText: String, phoneNumberText: String, transferAmountText: String) {
        guard let selectedExchangeRate = selectedExchangeRate,
              !fullNameText.isEmpty,
              !countryText.isEmpty,
              !phoneNumberText.isEmpty,
              !transferAmountText.isEmpty
        else {
            self.transactionValidation.onNext(false)
            return
        }
        
        let countryID = filterCountryFlag(from: countryText)
                
        getCountriesService.getCountry(from: countryID).subscribe(onNext :{ [weak self] country in
            guard let self = self else { return }
            
            let transactionResult =
                self.isValidPhoneNumber(for: country, and: phoneNumberText)
                && self.isValidTransferAmount(for: transferAmountText)
            self.transactionValidation.onNext(transactionResult)
            self.transactionInformation.onNext((transactionResult, fullNameText, countryID, selectedExchangeRate, transferAmountText))
            
        }).disposed(by: disposeBag)
    }
    
    private func getTransactionMessage(recipient: String, country: String, exchangeRate: ExchangeRate, amount: String) {
        binaryConverterService.toDecimal(binary: amount).subscribe(onNext :{ [weak self] amountInDecimal in
            guard let self = self else { return }
            
            let totalAmountInForeignCurrency = Double(amountInDecimal) * exchangeRate

            self.binaryConverterService.toBinary(decimal: totalAmountInForeignCurrency).subscribe(onNext :{ [weak self] amountInBinarian in
                guard let self = self else { return }
                
                self.contructTransactionMessage(for: recipient, amount: amountInBinarian, exchangeRate: exchangeRate, recipientCountry: country)
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
    
    private func contructTransactionMessage(for recipientName: String, amount: String, exchangeRate: Double, recipientCountry: String) {
        let convertionExpression = "(1 Binarian = " + String(exchangeRate) + " " +  String(recipientCountry) + ")"
        let message = recipientName + " will recieve " + "\n" + amount + "\n" + convertionExpression
        
        self.transactionMessage.onNext(message)
    }
    
    private func isValidPhoneNumber(for country: Country, and number: String) -> Bool {
        number.starts(with: country.phonePrefix) && (number.count - (country.phonePrefix.count)) == country.numberOfDigitsAfterPrefix
    }
    
    private func isValidTransferAmount(for transferAmount: String) -> Bool {
        !(transferAmount.count > 30) && transferAmount != "0"
    }
    
    private func filterCountryFlag(from text: String) -> String {
        text.unicodeScalars
            .filter { !$0.properties.isEmojiPresentation }
            .reduce("") { $0 + String($1) }.replacingOccurrences(of: " ", with: "")
    }
}
