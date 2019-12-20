//
//  CombineViewModel.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 12/19/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class CombineViewModel: ObservableObject {
    let api = CombineAPI.shared
    var cancellable: AnyCancellable?

    @Published var forecasts = [Forecast]()

    func refresh() {
        cancellable?.cancel()
        cancellable = api.getForecasts()
            .receive(on: RunLoop.main)
            .catch { error -> Just<[Forecast]> in
                self.handle(error: error)
                return Just([])
            }
            .assign(to: \.forecasts, on: self)
    }

    func reset() {
        _ = Just([]).assign(to: \.forecasts, on: self)
    }

    private func handle(error: Error) {
        if let error = error as? CombineAPI.CombineError {
            switch error {
            case .badResponse:
                print("bad response")
            case .badRequest(let error):
                print(error.localizedDescription)
            case .badUrl:
                assertionFailure("bad url")
            }
        } else {
            print("Combine Error: \(error).\n\nDescription: \(error.localizedDescription)")
        }
    }

    // As of iOS 13.3, NavigationLink does not release its destination views (and by extension, this view model)
    // https://medium.com/better-programming/swiftui-101-how-not-to-initialize-bindable-objects-6e539d1b5344
    deinit {
        print("********** COMBINE VIEW MODEL DEINIT **********")
    }
}
