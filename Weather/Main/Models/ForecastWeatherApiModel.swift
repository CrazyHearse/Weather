//
//  ForecastWeatherApiModel.swift
//  Weather
//
//  Created by Евгений Ерофеев on 30.03.22.
//

import Foundation

// MARK: - ForecastForNext5days
struct ForecastWeather: Codable {
    var list: [WeatherForHour]
    let city: City
    
// MARK: - List
    struct WeatherForHour: Codable {
        let dt: Int
        let main: MainClass
        let weather: [Weather]
    }
    
// MARK: - MainClass
    struct MainClass: Codable {
        let temp: Double
    }
    
// MARK: - Weather
    struct Weather: Codable {
        let description: String
        let icon: String
    }
    
// MARK: - City
    struct City: Codable {
        let name: String
    }
}

