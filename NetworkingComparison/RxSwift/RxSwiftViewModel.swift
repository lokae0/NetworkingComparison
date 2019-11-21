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

    let forecasts = PublishRelay<[Forecast]>()

    func refresh() {
        api.getForecasts()
            .subscribe(
                onNext: { self.forecasts.accept($0) },
                onError: { self.handle(error: $0) }
            )
            .disposed(by: bag)
    }

    private func handle(error: Error) {
        print("RxSwift Error: \(error).\n\nDescription: \(error.localizedDescription)")
    }
}
