//
//  RxSwiftViewModel.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 11/19/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RxSwiftViewModel {
    let api = RxSwiftAPI.shared
    let bag = DisposeBag()

    var forecasts: Driver<[Forecast]> {
        forecastsRelay.asDriver(onErrorJustReturn: [])
    }

    private let forecastsRelay = PublishRelay<[Forecast]>()

    func refresh() {
        api.getForecasts()
            .retry(3)
            .catchError {
                self.handle(error: $0)
                return Observable.just([])
            }
            .subscribe(onNext: { self.forecastsRelay.accept($0) })
            .disposed(by: bag)
    }

    private func handle(error: Error) {
        print("RxSwift Error: \(error).\n\nDescription: \(error.localizedDescription)")
    }
}
