//
//  CombineForecastView.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 12/19/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import SwiftUI

struct CombineForecastView: View {
    @ObservedObject var viewModel = CombineViewModel()

    var body: some View {
        List(viewModel.forecasts, id: \.date) { forecast in
            Text(forecast.date.description)
            Text(forecast.description)
        }
        .onAppear {
            self.viewModel.refresh()
        }
    }
}

struct CombineForecastView_Previews: PreviewProvider {
    static var previews: some View {
        CombineForecastView()
    }
}
