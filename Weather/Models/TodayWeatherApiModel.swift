//
//  TodayWeatherApiModel.swift
//  Weather
//
//  Created by Евгений Ерофеев on 29.03.22.
//

import Foundation

// locationApi model
struct LocationApi: Codable {
    let city: City
    struct City: Codable {
        let name: String
        let country: String
    }
}

// temperature model
struct Temp: Codable {
    let day: Double
}

// weather model
struct Weather: Codable {
    let id: Int
    let main: String
    let weatherDescription: String
    let icon: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case main
        case weatherDescription = "description"
        case icon
    }
}

// everyday (daily) model
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
        case weather
        case pop
        case snow
        case rain
    }
}

// today (actual or current) model
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

// today (current or actual) weather model
struct TodayWeather: Codable {
    let today: Today
    let daily: [Daily]
    
    enum CodingKeys: String, CodingKey {
        case today
        case daily
    }
}
