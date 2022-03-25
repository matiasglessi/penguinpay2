//
//  SendTransactionViewModelTests.swift
//  PenguinPay2Tests
//
//  Created by Matias Glessi on 25/03/2022.
//

import XCTest
import RxSwift

@testable import PenguinPay2

class SendTransactionViewModelTests: XCTestCase {
    
    private let getExchangeService = GetExchangeRateServiceMock()
    private let getCountriesService = GetCountriesServiceMock()
    private let binaryConverterService = BinaryConverterServiceMock()
    private let disposeBag = DisposeBag()
        
    func test_onGetExchangeRate_callsGetExchangeRateService() {
        let expectation = self.expectation(description: #function)
        let viewModel = makeSUT()

        let exchangeRate: ExchangeRate = 1000.0
        getExchangeService.exchangeRateReturnValue = exchangeRate
    
        viewModel.exchangeRate.subscribe(onNext :{ [weak self] returnedExchangeRate in
            guard let self = self else {
                XCTFail()
                return
            }
            
            expectation.fulfill()
            XCTAssertEqual(returnedExchangeRate, exchangeRate)
            XCTAssert(self.getExchangeService.isCalled())
            

        }).disposed(by: disposeBag)

        
        viewModel.getExchangeRate(for: "NGN")
        
        wait(for: [expectation], timeout: 2)
    }
    
    
    func test_onValidateTransactionInformation_withValidParameters_callsCountryService() {
        let expectation = self.expectation(description: #function)
        let viewModel = makeSUT()

        let country = Country(id: "TZS", name: "Tanzania", flag: "🇹🇿", phonePrefix: "+255", numberOfDigitsAfterPrefix: 9)
        let recipientName = "Matias Glessi"
        let countryID = country.id
        let phoneNumber = "+255987987987"
        let transferAmount = "10011"
        getCountriesService.countryReturnValue = country
        
        let exchangeRate: ExchangeRate = 1000.0
        getExchangeService.exchangeRateReturnValue = exchangeRate

        viewModel.transactionValidation.subscribe(onNext :{ [weak self] _ in
            guard let self = self else {
                XCTFail()
                return
            }
            
            expectation.fulfill()
            XCTAssert(self.getCountriesService.isGetCountryCalled())
            
        }).disposed(by: disposeBag)

        viewModel.getExchangeRate(for: "NGN")
        viewModel.validateTransactionInformation(fullNameText: recipientName, countryText: countryID, phoneNumberText: phoneNumber, transferAmountText: transferAmount)
        
        wait(for: [expectation], timeout: 2)
    }
    
    
    func test_onValidateTransactionInformation_withValidParameters_validatesTransaction() {
        let expectation = self.expectation(description: #function)
        let viewModel = makeSUT()

        let country = Country(id: "TZS", name: "Tanzania", flag: "🇹🇿", phonePrefix: "+255", numberOfDigitsAfterPrefix: 9)
        let recipientName = "Matias Glessi"
        let countryID = country.id
        let phoneNumber = "+255987987987"
        let transferAmount = "10011"
        getCountriesService.countryReturnValue = country
        
        let exchangeRate: ExchangeRate = 1000.0
        getExchangeService.exchangeRateReturnValue = exchangeRate

        viewModel.transactionValidation.subscribe(onNext :{ isValidTransaction in
            expectation.fulfill()
            XCTAssert(isValidTransaction)
        }).disposed(by: disposeBag)

        viewModel.getExchangeRate(for: "NGN")
        viewModel.validateTransactionInformation(fullNameText: recipientName, countryText: countryID, phoneNumberText: phoneNumber, transferAmountText: transferAmount)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_onValidateTransactionInformation_withValidParameters_callsBinaryConverterService() {
        let expectation = self.expectation(description: #function)
        let viewModel = makeSUT()

        let country = Country(id: "TZS", name: "Tanzania", flag: "🇹🇿", phonePrefix: "+255", numberOfDigitsAfterPrefix: 9)
        let recipientName = "Matias Glessi"
        let countryID = country.id
        let phoneNumber = "+255987987987"
        let transferAmount = "10011"
        getCountriesService.countryReturnValue = country
        
        let exchangeRate: ExchangeRate = 1000.0
        getExchangeService.exchangeRateReturnValue = exchangeRate

        viewModel.transactionMessage.subscribe(onNext :{ [weak self] _ in
            guard let self = self else {
                XCTFail()
                return
            }
            
            expectation.fulfill()
            XCTAssert(self.binaryConverterService.isToBinaryCalled())
            XCTAssert(self.binaryConverterService.isToDecimalCalled())

        }).disposed(by: disposeBag)

        viewModel.getExchangeRate(for: "NGN")
        viewModel.validateTransactionInformation(fullNameText: recipientName, countryText: countryID, phoneNumberText: phoneNumber, transferAmountText: transferAmount)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_onValidateTransactionInformation_withValidParameters_sendCorrectMessage() {
        let expectation = self.expectation(description: #function)
        let viewModel = makeSUT()

        let country = Country(id: "TZS", name: "Tanzania", flag: "🇹🇿", phonePrefix: "+255", numberOfDigitsAfterPrefix: 9)
        let recipientName = "Matias Glessi"
        let countryID = country.id
        let phoneNumber = "+255987987987"
        let transferAmount = "10011"
        let amountInBinary = "1010"
        let exchangeRate: ExchangeRate = 1000.0
       
        getExchangeService.exchangeRateReturnValue = exchangeRate
        getCountriesService.countryReturnValue = country
        binaryConverterService.binaryReturnValue = amountInBinary
        
        let message = constructTransactionMessage(recipientName, amountInBinary, exchangeRate, countryID)
        
        viewModel.transactionMessage.subscribe(onNext :{ returnedMessage in
            expectation.fulfill()
            XCTAssertEqual(returnedMessage, message)

        }).disposed(by: disposeBag)

        viewModel.getExchangeRate(for: "NGN")
        viewModel.validateTransactionInformation(fullNameText: recipientName, countryText: countryID, phoneNumberText: phoneNumber, transferAmountText: transferAmount)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_onValidateTransactionInformation_withZeroAmount_doesNotValidateTransaction () {
        let expectation = self.expectation(description: #function)
        let viewModel = makeSUT()

        let country = Country(id: "TZS", name: "Tanzania", flag: "🇹🇿", phonePrefix: "+255", numberOfDigitsAfterPrefix: 9)
        let recipientName = "Matias Glessi"
        let countryID = country.id
        let phoneNumber = "+255987987987"
        let transferAmount = "0"
        getCountriesService.countryReturnValue = country
        
        let exchangeRate: ExchangeRate = 1000.0
        getExchangeService.exchangeRateReturnValue = exchangeRate

        viewModel.transactionValidation.subscribe(onNext :{ isValidTransaction in
            expectation.fulfill()
            XCTAssertFalse(isValidTransaction)
        }).disposed(by: disposeBag)

        viewModel.getExchangeRate(for: "NGN")
        viewModel.validateTransactionInformation(fullNameText: recipientName, countryText: countryID, phoneNumberText: phoneNumber, transferAmountText: transferAmount)
        
        wait(for: [expectation], timeout: 2)
    }

    
    func test_onValidateTransactionInformation_withMoreThan30DigitsForAmount_doesNotValidateTransaction () {
        let expectation = self.expectation(description: #function)
        let viewModel = makeSUT()

        let country = Country(id: "TZS", name: "Tanzania", flag: "🇹🇿", phonePrefix: "+255", numberOfDigitsAfterPrefix: 9)
        let recipientName = "Matias Glessi"
        let countryID = country.id
        let phoneNumber = "+255987987987"
        let transferAmount = "1010100011010110000111010101011"
        getCountriesService.countryReturnValue = country
        
        let exchangeRate: ExchangeRate = 1000.0
        getExchangeService.exchangeRateReturnValue = exchangeRate

        viewModel.transactionValidation.subscribe(onNext :{ isValidTransaction in
            expectation.fulfill()
            XCTAssertFalse(isValidTransaction)
        }).disposed(by: disposeBag)

        viewModel.getExchangeRate(for: "NGN")
        viewModel.validateTransactionInformation(fullNameText: recipientName, countryText: countryID, phoneNumberText: phoneNumber, transferAmountText: transferAmount)
        
        wait(for: [expectation], timeout: 2)
    }

    
    
    func test_onValidateTransactionInformation_withInvalidPhoneNumber_doesNotValidateTransaction () {
        let expectation = self.expectation(description: #function)
        let viewModel = makeSUT()

        let country = Country(id: "TZS", name: "Tanzania", flag: "🇹🇿", phonePrefix: "+255", numberOfDigitsAfterPrefix: 9)
        let recipientName = "Matias Glessi"
        let countryID = country.id
        let phoneNumber = "+25598798798"
        let transferAmount = "10011"
        getCountriesService.countryReturnValue = country
        
        let exchangeRate: ExchangeRate = 1000.0
        getExchangeService.exchangeRateReturnValue = exchangeRate

        viewModel.transactionValidation.subscribe(onNext :{ isValidTransaction in
            expectation.fulfill()
            XCTAssertFalse(isValidTransaction)
        }).disposed(by: disposeBag)

        viewModel.getExchangeRate(for: "NGN")
        viewModel.validateTransactionInformation(fullNameText: recipientName, countryText: countryID, phoneNumberText: phoneNumber, transferAmountText: transferAmount)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_onValidateTransactionInformation_withoutExchangeRateSelected_doesNotValidateTransaction () {
        let expectation = self.expectation(description: #function)
        expectation.isInverted = true
        
        let viewModel = makeSUT()

        let country = Country(id: "TZS", name: "Tanzania", flag: "🇹🇿", phonePrefix: "+255", numberOfDigitsAfterPrefix: 9)
        let recipientName = "Matias Glessi"
        let countryID = country.id
        let phoneNumber = "+25598798798"
        let transferAmount = "10011"
        getCountriesService.countryReturnValue = country
        
        let exchangeRate: ExchangeRate = 1000.0
        getExchangeService.exchangeRateReturnValue = exchangeRate

        viewModel.transactionValidation.subscribe(onNext :{ isValidTransaction in
            expectation.fulfill()
            XCTAssert(isValidTransaction)
        }).disposed(by: disposeBag)

        viewModel.validateTransactionInformation(fullNameText: recipientName, countryText: countryID, phoneNumberText: phoneNumber, transferAmountText: transferAmount)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_onValidateTransactionInformation_withEmptyParameter_doesNotValidateTransaction () {
        let expectation = self.expectation(description: #function)
        expectation.isInverted = true
        
        let viewModel = makeSUT()

        let country = Country(id: "TZS", name: "Tanzania", flag: "🇹🇿", phonePrefix: "+255", numberOfDigitsAfterPrefix: 9)
        let countryID = country.id
        let phoneNumber = "+25598798798"
        let transferAmount = "10011"
        getCountriesService.countryReturnValue = country
        
        let exchangeRate: ExchangeRate = 1000.0
        getExchangeService.exchangeRateReturnValue = exchangeRate

        viewModel.transactionValidation.subscribe(onNext :{ isValidTransaction in
            expectation.fulfill()
            XCTAssert(isValidTransaction)
        }).disposed(by: disposeBag)

        viewModel.validateTransactionInformation(fullNameText: "", countryText: countryID, phoneNumberText: phoneNumber, transferAmountText: transferAmount)
        
        wait(for: [expectation], timeout: 1)
    }
    
    
    
    
    private func constructTransactionMessage(_ recipientName: String, _ amountInBinary: String, _ exchangeRate: Double, _ countryID: String) -> String {
        let convertionExpression = "(1 Binarian = " + String(exchangeRate) + " " +  countryID + ")"
        
        return recipientName
            + " "
            + "will recieve"
            + " "
            + "\n" + amountInBinary + "\n"
            + convertionExpression
    }
    
    
    private func makeSUT() -> SendTransactionViewModel {
        SendTransactionViewModel(
            getExchangeService: getExchangeService,
            getCountriesService: getCountriesService,
            binaryConverterService: binaryConverterService)
    }
}

