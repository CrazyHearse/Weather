//
//  TodayWeatherApiModel.swift
//  Weather
//
//  Created by Евгений Ерофеев on 29.03.22.
//

import Foundation

// MARK: - TodayWeather
struct TodayWeather: Codable {
    let current: Today
    let daily: [Daily]
    
    enum CodingKeys: String, CodingKey {
        case current, daily
    }
}

// MARK: - Today
struct Today: Codable {
    let temp: Double
    let pressure: Int
    let windSpeed: Double
    let windDeg: Int
    let weather: [Weather]
    
    enum CodingKeys: String, CodingKey {
        case temp
        case pressure
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case weather
    }
}

// MARK: - Weather
struct Weather: Codable {
    let id: Int
    let main, weatherDescription, icon: String
    
    enum CodingKeys: String, CodingKey {
        case id, main
        case weatherDescription = "description"
        case icon
    }
}

// MARK: - Daily
struct Daily: Codable {
    let temp: Temp
    let pressure: Int
    let weather: [Weather]
    let pop: Double
    let snow: Double?
    let rain: Double?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case pressure
        case weather, pop, snow, rain
    }
}

// MARK: - Temperature
struct Temp: Codable {
    let day: Double
}

// MARK: - LocationApi
struct LocationApi: Codable {
    let city: City
    struct City: Codable {
        let name: String
        let country: String
    }
}
