//
//  RxForecastViewController.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 11/20/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RxForecastViewController: UITableViewController {

    private let cellReuseIdentifier = "cell"
    private let bag = DisposeBag()

    private let viewModel: RxSwiftViewModel

    init(viewModel: RxSwiftViewModel) {
        self.viewModel = viewModel
        super.init(style: .plain)
        viewModel.refresh()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        bindViewModel()

        refreshControl = UIRefreshControl()
        refreshControl?.rx.controlEvent(.valueChanged)
            .subscribe(onNext: viewModel.refresh)
            .disposed(by: bag)
    }

    private func bindViewModel() {
        viewModel.forecasts
            .observeOn(MainScheduler.instance)
            .do(onNext: { _ in self.refreshControl?.endRefreshing() })
            .bind(to: tableView.rx.items(cellIdentifier: cellReuseIdentifier, cellType: SubtitleCell.self)) {
                _, forecast, cell in
                cell.update(forecast: forecast)
            }
            .disposed(by: bag)

    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
