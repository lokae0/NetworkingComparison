//
//  AlamofireAPI.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 10/31/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireAPI {
    static let shared = AlamofireAPI()

    private enum RequestStyle {
        case router, params, encodable
    }

    private var requestStyle: RequestStyle = .router

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    func getForecasts(completion: @escaping (AFResult<[CodableForecast]>) -> Void) {
        switch requestStyle {
        case .router: requestWithRouter(completion)
        case .params: requestWithParams(completion)
        case .encodable: requestWithEncodable(completion)
        }
    }

    private func requestWithRouter(_ completion: @escaping (AFResult<[CodableForecast]>) -> Void) {
        print("********** Alamofire requesting with URLRequestConvertible Router **********")

        AF.request(Router.forecast)
            .validate()
            .responseDecodable(of: CodableForecastWrapper.self, decoder: decoder) { [weak self] response in
                let forecastResult = response.map { $0.forecasts }.result
                completion(forecastResult)

                self?.requestStyle = .params
        }
    }

    private func requestWithParams(_ completion: @escaping (AFResult<[CodableForecast]>) -> Void) {
        print("********** Alamofire requesting with URLConvertible and Parameter Dictionary **********")

        AF.request(API.baseUrl, parameters: API.params, encoding: URLEncoding.queryString)
            .validate()
            .responseJSON { [weak self] response in
                print(response)
                self?.requestStyle = .encodable
        }
    }

    private func requestWithEncodable(_ completion: @escaping (AFResult<[CodableForecast]>) -> Void) {
        print("********** Alamofire requesting with URLConvertible and Encodable parameter model **********")

        struct Params: Codable {
            let zipCode: String
            let appId: String
            let units: String

            private enum CodingKeys: String, CodingKey {
                case zipCode = "zip"
                case appId = "appid"
                case units
            }
        }
        guard let zip = API.params["zip"], let appId = API.params["appid"], let units = API.params["units"] else {
            fatalError("Invalid param keys")
        }
        let encodableParams = Params(zipCode: zip, appId: appId, units: units)

        let request = AF.request(
            API.baseUrl,
            parameters: encodableParams,
            encoder: URLEncodedFormParameterEncoder(destination: .queryString)
        )
        request.validate().responseJSON { [weak self] response in
            print(response)
            self?.requestStyle = .router
        }
    }
}

enum Router: URLRequestConvertible {
    case forecast

    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters) = {
            switch self {
            case .forecast:
                return ("/forecast", API.params)
            }
        }()

        let url = try API.baseUrl.asURL()
        let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))

        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
    }
}
