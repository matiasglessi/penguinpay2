//
//  SendTransactionViewController.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 24/03/2022.
//

import UIKit
import RxSwift
import RxCocoa

class SendTransactionViewController: UIViewController {
    
    struct UI {
        struct Colors {
            static let primary = UIColor(red: 0.93, green: 0.61, blue: 0.00, alpha: 1.00)
            static let background = UIColor(red: 1.00, green: 0.91, blue: 0.84, alpha: 1.00)
        }
        struct Dimensions {
            static let leadingSpace: CGFloat = 10
            static let trailingSpace: CGFloat = -10
            static let spaceBetweenElements: CGFloat = 10
        }
    }
    
    private let recipientView: UIView
    private let recipientTitleLabel: UILabel
    private let fullNameTextField: UITextField
    private let countryTextField: UITextField
    private let phoneNumberTextField: UITextField
    
    private let transferView: UIView
    private let transferTitleLabel: UILabel
    private let transferAmountTextField: UITextField
    private let transferMessageLabel: UILabel
    
    private let sendTransferButton: UIButton
    
    private let disposeBag = DisposeBag()
    private let viewModel: SendTransactionViewModel
    private let isButtonEnabled = BehaviorRelay<Bool>(value: false)

    
    init(viewModel: SendTransactionViewModel) {
        self.viewModel = viewModel
        
        recipientView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UI.Colors.primary
            view.layer.cornerRadius = 5
            return view
        }()
        
        recipientTitleLabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "☺️ Recipient"
            return label
        }()
        
        fullNameTextField = {
            let textField = UITextField()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.placeholder = "Full name"
            textField.borderStyle = .roundedRect
            return textField
        }()
        
        countryTextField = {
            let textField = UITextField()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.placeholder = "Country"
            textField.borderStyle = .roundedRect
            textField.rightViewMode = .always
            textField.rightView = UIImageView(image: UIImage.init(systemName: "chevron.down"))
            return textField
        }()
        
        phoneNumberTextField = {
            let textField = UITextField()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.placeholder = "Phone Number"
            textField.borderStyle = .roundedRect
            textField.keyboardType = .phonePad
            return textField
        }()
        
        transferView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 5
            view.backgroundColor = UI.Colors.primary
            return view
        }()
        
        transferTitleLabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "💵 Transfer"
            return label
        }()
        
        transferAmountTextField = {
            let textField = UITextField()
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.placeholder = "$ 0"
            textField.borderStyle = .roundedRect
            textField.keyboardType = .numberPad
            return textField
        }()

        transferMessageLabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            return label
        }()
        
        sendTransferButton = {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setTitle("Send", for: .normal)
            button.layer.cornerRadius = 5
            button.disable()
            return button
        }()
    
        super.init(nibName: .none, bundle: .none)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        setScreenTitle()
        constructSubviews()
        
        bindViewModel()
        bindCountryPicker()
        bindTextFields()
        bindTransferButton()
        bindHideKeyboard()
        observeTexFields()
    }
    
    private func bindHideKeyboard() {
        let tapGesture = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGesture)

        tapGesture.rx.event.bind(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.hideKeyboard()
        }).disposed(by: disposeBag)
    }

    private func bindViewModel() {
        viewModel.transactionValidation.observe(on: MainScheduler.instance).subscribe { [weak self] isEnabled in
            isEnabled ? self?.sendTransferButton.enable() :
                self?.sendTransferButton.disable()
        }.disposed(by: disposeBag)
        
        viewModel.transactionMessage.observe(on: MainScheduler.instance).subscribe { [weak self] message in
            self?.transferMessageLabel.text = message
        }.disposed(by: disposeBag)
        
        viewModel.exchangeRate.observe(on: MainScheduler.instance).subscribe { [weak self] _ in
            
            guard let self = self else { return }
            
            self.validateTransaction(self.fullNameTextField.text ?? "", self.phoneNumberTextField.text ?? "", self.transferAmountTextField.text ?? "")

        }.disposed(by: disposeBag)
    }
    
    private func observeTexFields() {

        Observable
            .combineLatest(
                fullNameTextField.rx.text,
                countryTextField.rx.text,
                phoneNumberTextField.rx.text,
                transferAmountTextField.rx.text,
                
                resultSelector: { [weak self] fullName, country, phoneNumber, amount -> Void in
                    guard let self = self else { return }
                    
                    self.validateTransaction(fullName ?? "", phoneNumber ?? "", amount ?? "")
                    
                }).observe(on: MainScheduler.instance)
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    private func validateTransaction(_ fullName: String, _ phone: String, _ amount: String) {

        let country = self.countryTextField.text ?? ""
        let phoneNumber = (self.applyPhonePattern(phone)).replacingOccurrences(of: " ", with: "")
        let transferAmount = self.applyBinaryOnlyPattern(amount)

        
        
        self.viewModel.validateTransactionInformation(fullNameText: fullName, countryText: country, phoneNumberText: phoneNumber, transferAmountText: transferAmount)
    }
    
    private func hideKeyboard() {
        [fullNameTextField, phoneNumberTextField, transferAmountTextField].forEach { $0.resignFirstResponder() }
    }
    
    private func bindTransferButton() {
        sendTransferButton.rx.tap.throttle(RxTimeInterval.microseconds(5), latest: false, scheduler: MainScheduler.instance).subscribe { [weak self] _ in
            guard let self = self else { return }
            
            self.hideKeyboard()
            
            let message = ""
            
            let transactionAlert = UIAlertController(title: "Transaction sent", message: message, preferredStyle: .alert)
            transactionAlert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            self.present(transactionAlert, animated: true)

        }.disposed(by: disposeBag)
    }
        
    private func bindCountryPicker() {
        let tapGesture = UITapGestureRecognizer()
        countryTextField.addGestureRecognizer(tapGesture)

        tapGesture.rx.event.bind(onNext: { [weak self] recognizer in
            guard let strongSelf = self else { return }
            
            let countryListViewModel = CountriesListViewModel(getCountriesService: DefaultGetCountriesService())
            let countryPickerViewController = CountriesListViewController(viewModel: countryListViewModel)
            
            countryPickerViewController.countrySelected.subscribe(onNext :{ [weak self] country in
                self?.countryTextField.text = country.flag + " " + country.id
                self?.phoneNumberTextField.text = country.phonePrefix
                self?.phoneNumberTextField.becomeFirstResponder()
                self?.viewModel.getExchangeRate(for: country.id)
                self?.navigationController?.popViewController(animated: true)
            }).disposed(by: strongSelf.disposeBag)
            
            strongSelf.navigationController?.pushViewController(countryPickerViewController, animated: true)
        }).disposed(by: disposeBag)
    }
    
    private func bindTextFields() {
        transferAmountTextField.rx.text.orEmpty
            .map(applyBinaryOnlyPattern)
            .subscribe(onNext: setPreservingCursor(on: transferAmountTextField))
            .disposed(by: disposeBag)
        
        phoneNumberTextField.rx.text.orEmpty
            .map(applyPhonePattern)
            .subscribe(onNext:
                setPreservingCursor(on: phoneNumberTextField))
            .disposed(by: disposeBag)
    }


    func setPreservingCursor(on textField: UITextField) -> (_ newText: String) -> Void {
        return { newText in
            let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: textField.selectedTextRange!.start) + newText.count - (textField.text?.count ?? 0)
            textField.text = newText
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: cursorPosition) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    
    private func applyPhonePattern(_ text: String) -> String {
        let pattern = "+### ### ### ####"
        let replacement: Character = "#"
        var value = text.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < value.count else { return value }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacement else { continue }
            value.insert(patternCharacter, at: stringIndex)
        }
        return value
    }
    

    private func applyBinaryOnlyPattern(_ text: String) -> String {
        return text.filter({ "01".contains($0) })
    }

    private func setScreenTitle() {
        self.title = "Send Transaction"
    }
    
    private func constructSubviews() {
        let safeAreaGuide = self.view.safeAreaLayoutGuide
        self.view.backgroundColor = UI.Colors.background
        
        view.addSubview(recipientView)

        recipientView.topAnchor.constraint(equalTo: safeAreaGuide.topAnchor, constant: UI.Dimensions.spaceBetweenElements).isActive = true
        recipientView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor, constant: UI.Dimensions.leadingSpace).isActive = true
        recipientView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor, constant: UI.Dimensions.trailingSpace).isActive = true
        recipientView.heightAnchor.constraint(equalToConstant: 140).isActive = true
        
        recipientView.addSubview(recipientTitleLabel)
        
        recipientTitleLabel.topAnchor.constraint(equalTo: recipientView.topAnchor, constant: UI.Dimensions.spaceBetweenElements).isActive = true
        recipientTitleLabel.leadingAnchor.constraint(equalTo: recipientView.leadingAnchor, constant: UI.Dimensions.leadingSpace).isActive = true

        recipientView.addSubview(fullNameTextField)
        
        fullNameTextField.topAnchor.constraint(equalTo: recipientTitleLabel.bottomAnchor, constant: UI.Dimensions.spaceBetweenElements).isActive = true
        fullNameTextField.leadingAnchor.constraint(equalTo: recipientView.leadingAnchor, constant: UI.Dimensions.leadingSpace).isActive = true
        fullNameTextField.trailingAnchor.constraint(equalTo: recipientView.trailingAnchor, constant: UI.Dimensions.trailingSpace).isActive = true

        recipientView.addSubview(countryTextField)
        recipientView.addSubview(phoneNumberTextField)
        
        countryTextField.topAnchor.constraint(equalTo: fullNameTextField.bottomAnchor, constant: UI.Dimensions.spaceBetweenElements).isActive = true
        countryTextField.leadingAnchor.constraint(equalTo: recipientView.leadingAnchor, constant: UI.Dimensions.leadingSpace).isActive = true
        countryTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true

        phoneNumberTextField.topAnchor.constraint(equalTo: fullNameTextField.bottomAnchor, constant: UI.Dimensions.spaceBetweenElements).isActive = true
        phoneNumberTextField.leadingAnchor.constraint(equalTo: countryTextField.trailingAnchor, constant: UI.Dimensions.leadingSpace).isActive = true
        phoneNumberTextField.trailingAnchor.constraint(equalTo: recipientView.trailingAnchor, constant: UI.Dimensions.trailingSpace).isActive = true

        view.addSubview(transferView)

        transferView.topAnchor.constraint(equalTo: recipientView.bottomAnchor, constant: UI.Dimensions.spaceBetweenElements).isActive = true
        transferView.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor, constant: UI.Dimensions.leadingSpace).isActive = true
        transferView.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor, constant: UI.Dimensions.trailingSpace).isActive = true
        transferView.heightAnchor.constraint(greaterThanOrEqualToConstant: 160).isActive = true

        transferView.addSubview(transferTitleLabel)
        
        transferTitleLabel.topAnchor.constraint(equalTo: transferView.topAnchor, constant: UI.Dimensions.spaceBetweenElements).isActive = true
        transferTitleLabel.leadingAnchor.constraint(equalTo: transferView.leadingAnchor, constant: UI.Dimensions.leadingSpace).isActive = true
        
        transferView.addSubview(transferAmountTextField)
        
        transferAmountTextField.topAnchor.constraint(equalTo: transferTitleLabel.bottomAnchor, constant: UI.Dimensions.spaceBetweenElements).isActive = true
        transferAmountTextField.leadingAnchor.constraint(equalTo: transferView.leadingAnchor, constant: UI.Dimensions.leadingSpace).isActive = true
        transferAmountTextField.trailingAnchor.constraint(equalTo: transferView.trailingAnchor, constant: UI.Dimensions.trailingSpace).isActive = true

        transferView.addSubview(transferMessageLabel)

        transferMessageLabel.topAnchor.constraint(equalTo: transferAmountTextField.bottomAnchor, constant: UI.Dimensions.spaceBetweenElements).isActive = true
        transferMessageLabel.leadingAnchor.constraint(equalTo: transferView.leadingAnchor, constant: UI.Dimensions.leadingSpace).isActive = true
        transferMessageLabel.trailingAnchor.constraint(equalTo: transferView.trailingAnchor, constant: UI.Dimensions.trailingSpace).isActive = true
        transferMessageLabel.bottomAnchor.constraint(equalTo: transferView.bottomAnchor, constant: -UI.Dimensions.spaceBetweenElements).isActive = true

        view.addSubview(sendTransferButton)

        sendTransferButton.topAnchor.constraint(equalTo: transferView.bottomAnchor, constant: UI.Dimensions.spaceBetweenElements).isActive = true
        sendTransferButton.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor, constant: UI.Dimensions.leadingSpace).isActive = true
        sendTransferButton.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor, constant: UI.Dimensions.trailingSpace).isActive = true
        sendTransferButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}
