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

    enum SessionStyle {
        case deferredRequest, observableRequest, manualResponse
    }

    typealias ForecastInfo = Observable<(forecasts: [Forecast], style: SessionStyle)>

    private let session = URLSession.shared

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()

    private init() { }

    func getForecasts(with style: SessionStyle) -> ForecastInfo {
        return data(for: style).map {
            let forecasts = try self.decoder.decode(ForecastWrapper.self, from: $0).forecasts
            return (forecasts, style)
        }
    }

    private func data(for style: SessionStyle) -> Observable<Data> {
        switch style {
        case .deferredRequest: return fetchWithDeferredRequest()
        case .observableRequest: return fetchWithObservableRequest()
        case .manualResponse: return fetchWithManualResponse()
        }
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

    /* Using deferred allows the URLRequest to be constructed at time of subscription, as opposed to time
     * of function call. This is preferable because:
     * B. Things may get out of date (params, auth, etc.) if returned Observable isn't subscribed to immediately.
     * C. Resources won't be allocated until they're actually needed (i.e. when subscription actually occurs).
     */
    private func fetchWithDeferredRequest() -> Observable<Data> {
        let session = self.session

        return Observable.deferred { [weak self] in
            print("********** RxSwift requesting with deferred URLRequest **********")

            guard let request = self?.urlRequest else {
                return Observable.error(RxSwiftError.badUrl)
            }
            return session.rx.data(request: request)
        }
    }

    // This also delays request construction until subscription time. Same benefit as above but different approach.
    private func fetchWithObservableRequest() -> Observable<Data> {
        let request: Observable<URLRequest> = Observable.create { [weak self] observer in
            print("********** RxSwift requesting with observable URLRequest **********")

            guard let urlRequest = self?.urlRequest else {
                observer.onError(RxSwiftError.badUrl)
                return Disposables.create()
            }
            observer.onNext(urlRequest)
            observer.onCompleted()

            return Disposables.create()
        }
        return request.flatMap(session.rx.data(request:))
    }

    private func fetchWithManualResponse() -> Observable<Data> {
        let session = self.session

        return Observable.deferred { [weak self] in
            print("********** RxSwift requesting with manual response handling **********")

            guard let request = self?.urlRequest else {
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
}
