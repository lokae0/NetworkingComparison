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

    private init() { }

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

        guard let url = URL(string: API.baseUrl)?.appendingPathComponent("forecast") else {
            completion(.failure(AFError.invalidURL(url: API.baseUrl)))
            return
        }
        AF.request(url, parameters: API.params, encoding: URLEncoding.queryString)
            .validate()
            .responseData { [weak self] response in
                let forecastResponse = response.map { data -> [CodableForecast] in
                    guard let wrapper = try? self?.decoder.decode(CodableForecastWrapper.self, from: data) else {
                        completion(.failure(.responseSerializationFailed(reason: .inputDataNilOrZeroLength)))
                        return []
                    }
                    return wrapper.forecasts.filter { $0.temp < 54 }
                }
                completion(forecastResponse.result)

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
            API.baseUrl.appending("/forecast"),
            parameters: encodableParams,
            encoder: URLEncodedFormParameterEncoder(destination: .queryString)
        )
        request.validate().responseDecodable(of: CodableForecastWrapper.self, decoder: decoder) { [weak self] response in
            let forecastResponse = response.map {
                $0.forecasts.filter { $0.temp > 60 }
            }
            completion(forecastResponse.result)

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
