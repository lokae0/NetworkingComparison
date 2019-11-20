//
//  AlamofireViewModel.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 10/31/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireViewModel: ForecastViewModel {
    let api = AlamofireAPI.shared

    func refresh(onSuccess: @escaping ([Forecast]) -> Void) {
        api.getForecasts { result in
            switch result {
            case .success(let forecasts):
                onSuccess(forecasts)
            case .failure(let failure):
                print("Alamofire Error: \(failure).\n\nDescription: \(failure.errorDescription ?? "")")
            }
        }
    }
}
