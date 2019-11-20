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

    var forecasts: Observable<[Forecast]> {
        return Observable.combineLatest(sessionStyle.asObservable(), deferredInfo, observableInfo, manualInfo) {
            style, deferredInfo, observableInfo, manualInfo in
            return [deferredInfo, observableInfo, manualInfo].first { $0.style == style }?.forecasts ?? []
        }
    }

    private var sessionStyle = BehaviorRelay<RxSwiftAPI.SessionStyle>(value: .deferredRequest)

    private let deferredInfo: RxSwiftAPI.ForecastInfo
    private let observableInfo: RxSwiftAPI.ForecastInfo
    private let manualInfo: RxSwiftAPI.ForecastInfo

    init() {
        deferredInfo = api.getForecasts(with: .deferredRequest)
        observableInfo = api.getForecasts(with: .observableRequest)
        manualInfo = api.getForecasts(with: .manualResponse)
    }

    func refresh() {
        switch sessionStyle.value {
        case .deferredRequest:
            sessionStyle.accept(.observableRequest)
        case .observableRequest:
            sessionStyle.accept(.manualResponse)
        case .manualResponse:
            sessionStyle.accept(.deferredRequest)
        }
    }
}
