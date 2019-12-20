//
//  ForecastRow.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 12/20/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import SwiftUI

struct ForecastRow: View {
    var forecast: Forecast

    var body: some View {
        VStack(alignment: .leading) {
            Text(forecast.formattedDescription)
            Text(forecast.formattedDate)
                .font(Font.system(size: 12.0))
        }
    }
}

struct ForecastRow_Previews: PreviewProvider {
    static var previews: some View {
        ForecastRow(forecast: Forecast.mockForecast())
    }
}
