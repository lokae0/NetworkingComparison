//
//  Forecast.swift
//  NetworkingComparison
//
//  Created by Ian Luo on 10/25/19.
//  Copyright © 2019 Lokae. All rights reserved.
//

import Foundation

struct ForecastWrapper: Decodable {
    let forecasts: [Forecast]

    private enum CodingKeys: String, CodingKey {
        case forecasts = "list"
    }
}

struct Forecast: Hashable, Decodable {
    let date: Date
    let temp: Double
    let description: String

    var formattedDescription: String {
        String(format: "%.1f °F and %@", temp, description)
    }

    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }

    private enum CodingKeys: String, CodingKey {
        case date = "dt"
        case main
        case weather
    }

    private enum MainCodingKeys: String, CodingKey {
        case temp
    }

    private struct WeatherInfo: Decodable {
        let description: String
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)

        let main = try container.nestedContainer(keyedBy: MainCodingKeys.self, forKey: .main)
        temp = try main.decode(Double.self, forKey: .temp)

        var weatherContainer = try container.nestedUnkeyedContainer(forKey: .weather)
        let weather = try weatherContainer.decode(WeatherInfo.self)
        description = weather.description
    }

    fileprivate init(date: Date, temp: Double, description: String) {
        self.date = date
        self.temp = temp
        self.description = description
    }
}

extension Forecast {
    static func mockForecast() -> Forecast {
        return Forecast(date: Date(), temp: 55.3, description: "light rain")

    }
}
