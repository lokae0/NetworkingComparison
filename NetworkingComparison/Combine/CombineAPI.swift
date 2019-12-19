//
//  CombineAPI.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 11/21/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import Foundation
import Combine

class CombineAPI {
    static let shared = CombineAPI()

    enum CombineError: Error {
        case badUrl, badRequest(Error), badResponse
    }

    private var urlRequest: URLRequest? {
        guard
            let pathUrl = URL(string: API.baseUrl)?.appendingPathComponent("forecast"),
            var components = URLComponents(url: pathUrl, resolvingAgainstBaseURL: true)
            else { return nil }

        components.queryItems = API.params.map { URLQueryItem(name: $0, value: $1) }
        guard let completeUrl = components.url else { return nil }
        return URLRequest(url: completeUrl)
    }

    private init() { }

    func getForecasts() -> AnyPublisher<[Forecast], Error> {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970

        guard let request = urlRequest else {
            return Fail(error: CombineError.badUrl).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { CombineError.badRequest($0) }
            .tryMap { output in
                guard
                    let response = output.response as? HTTPURLResponse,
                    case 200 ..< 300 = response.statusCode
                    else {
                        throw CombineError.badResponse
                }
                return output.data
            }
            .decode(type: ForecastWrapper.self, decoder: decoder)
            .map { $0.forecasts }
            .eraseToAnyPublisher()
    }
}
