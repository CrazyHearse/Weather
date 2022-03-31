//
//  ForecastWeatherViewModel.swift
//  Weather
//
//  Created by Евгений Ерофеев on 30.03.22.
//

import Foundation

struct ForecastWeatherViewModel {
    var days: [[Day]]
    let city: String
    struct Day {
        let day: String
        let temperature: Int
        let time: String
        let weatherDescription: String
        let weatherIcon: String
    }
}
