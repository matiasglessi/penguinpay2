//
//  CountriesListViewController.swift
//  PenguinPay2
//
//  Created by Matias Glessi on 24/03/2022.
//

import Foundation
import RxSwift
import RxCocoa

class CountriesListViewController: UIViewController, UITableViewDelegate {
    
    private let tableView: UITableView
    private let viewModel: CountriesListViewModel
    private let disposeBag = DisposeBag()
    
    var countrySelected: PublishSubject<Country> = PublishSubject()

    init(viewModel: CountriesListViewModel) {
        self.viewModel = viewModel
        tableView = {
            return UITableView()
        }()
        
        super.init(nibName: .none, bundle: .none)
    }
    
    required init?(coder aDecoder: NSCoder) { return nil }

    override func viewDidLoad() {
        constructSubviews()
        bindTableView()
        viewModel.getCountries()
    }
    
    private func bindTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")

        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.items.bind(to: tableView.rx.items(cellIdentifier: "UITableViewCell", cellType: UITableViewCell.self)) { (row,item,cell) in
            cell.textLabel?.text = item.flag + " " + item.name
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Country.self).observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] item in
            self?.countrySelected.onNext(item)
        }).disposed(by: disposeBag)
    }
    
    
    private func constructSubviews() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
    }
}
