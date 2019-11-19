//
//  RxSwiftAPI.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 11/18/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RxSwiftAPI {
    static let shared = RxSwiftAPI()

    enum RxSwiftError: Error {
        case badUrl, invalidKey, cityNotFound, serverFailure
    }

    private let session = URLSession.shared

    private enum SessionStyle {
        case observableRequest, standardRequest, manualResponse
    }

    private var sessionStyle: SessionStyle = .observableRequest

    private init() { }

    func getForecasts() -> Observable<[CodableForecast]> {
        var data: Observable<Data>
        switch sessionStyle {
        case .observableRequest: data = fetchWithStandardRequest()
        case .standardRequest: data = fetchWithObservableRequest()
        case .manualResponse: data = fetchWithManualResponse()
        }
        return data.map {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode(CodableForecastWrapper.self, from: $0).forecasts
        }
    }

    private func fetchWithStandardRequest() -> Observable<Data> {
        print("********** RxSwift requesting with standard URLRequest **********")
        defer { sessionStyle = .observableRequest }

        let urlRequest: URLRequest? = {
            guard
                let pathUrl = URL(string: API.baseUrl)?.appendingPathComponent("forecast"),
                var components = URLComponents(url: pathUrl, resolvingAgainstBaseURL: true)
                else { return nil }

            components.queryItems = API.params.map { URLQueryItem(name: $0, value: $1) }
            guard let completeUrl = components.url else { return nil }
            return URLRequest(url: completeUrl)
        }()
        guard let request = urlRequest else {
            return Observable.error(RxSwiftError.badUrl)
        }
        return session.rx.data(request: request)
    }

    private func fetchWithObservableRequest() -> Observable<Data> {
        print("********** RxSwift requesting with observable URLRequest **********")
        defer { sessionStyle = .manualResponse }

        // This is somewhat contrived. You can simply build a URLRequest the "standard" way
        // since the request doesn't change over time.
        let request: Observable<URLRequest> = Observable.create { observer in
            guard
                let pathUrl = URL(string: API.baseUrl)?.appendingPathComponent("forecast"),
                var components = URLComponents(url: pathUrl, resolvingAgainstBaseURL: true)
                else {
                    observer.onError(RxSwiftError.badUrl)
                    return Disposables.create()
            }
            components.queryItems = API.params.map { URLQueryItem(name: $0, value: $1) }
            guard let completeUrl = components.url else {
                observer.onError(RxSwiftError.badUrl)
                return Disposables.create()
            }
            observer.onNext(URLRequest(url: completeUrl))
            observer.onCompleted()

            return Disposables.create()
        }
        return request.flatMap(session.rx.data(request:))
    }

    private func fetchWithManualResponse() -> Observable<Data> {
        print("********** RxSwift requesting with manual response handling **********")
        defer { sessionStyle = .standardRequest }

        let urlRequest: URLRequest? = {
            guard
                let pathUrl = URL(string: API.baseUrl)?.appendingPathComponent("forecast"),
                var components = URLComponents(url: pathUrl, resolvingAgainstBaseURL: true)
                else { return nil }

            components.queryItems = API.params.map { URLQueryItem(name: $0, value: $1) }
            guard let completeUrl = components.url else { return nil }
            return URLRequest(url: completeUrl)
        }()
        guard let request = urlRequest else {
            return Observable.error(RxSwiftError.badUrl)
        }
        return session.rx.response(request: request).map { response, data in
            switch response.statusCode {
            case 200 ..< 300:
                return data
            case 401:
                throw RxSwiftError.invalidKey
            case 400 ..< 500:
                throw RxSwiftError.cityNotFound
            default:
                throw RxSwiftError.serverFailure
            }
        }
    }
}
