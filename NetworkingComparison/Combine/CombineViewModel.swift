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

    var forecasts = [Forecast]()

    func refresh() {
        cancellable?.cancel()
        let cancellable = api.getForecasts()
    }
}
