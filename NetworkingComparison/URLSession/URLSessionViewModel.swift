//
//  URLSessionViewModel.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 10/28/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import Foundation

class URLSessionViewModel: ForecastViewModel {
    let api = URLSessionAPI()

    func refresh(onSuccess: @escaping ([Forecast]) -> Void) {
        api.getForecasts { [weak self] result in
            switch result {
            case .success(let forecasts):
                onSuccess(forecasts)
            case .failure(let failure):
                self?.handle(failure: failure)
            }
        }
    }

    private func handle(failure: URLSessionAPI.APIError) {
        switch failure {
        case .badResponse:
            print("bad response")
        case .badRequest(let error):
            print(error.localizedDescription)
        case .badUrl:
            assertionFailure("bad url")
        }
    }
}
