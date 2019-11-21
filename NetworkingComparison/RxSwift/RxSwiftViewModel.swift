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

    var forecasts: Driver<[Forecast]> {
        api.getForecasts().asDriver(onErrorJustReturn: [])
    }
}
