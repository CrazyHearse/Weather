//
//  NetworkService.swift
//  Weather
//
//  Created by Евгений Ерофеев on 28.03.22.
//

import Foundation

//actual key for OpenWeatherMap: 58bd69efeab05012a439738eaf288394

enum RequestType {
    case current
    case forecast
}

class NetworkService {
    func getWeather<T: Codable>(
        for: T.Type = T.self,
        location: Location,
        request: RequestType,
        completion: @escaping ((Result<T?, Error>) -> Void)
    )
    {
        var url: String

        switch request {
        case .current:
            url = getURLForTodayWeatherRequest(location: location)
        case .forecast:
            url = getURLForForecastWeatherRequest(location: location)
        }

        guard let url = URL(string: url) else { return }

        URLSession.shared.dataTask(with: url) {data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            do {
                let obj = try JSONDecoder().decode(T.self, from: data!)
                completion(.success(obj))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func getURLForForecastWeatherRequest(location: Location) -> String {
        let locationParams = "lat=\(location.lat)&lon=\(location.lon)"
        let apiParam = "&appid=58bd69efeab05012a439738eaf288394"
        let url = "http://api.openweathermap.org/data/2.5/forecast?\(locationParams)\(apiParam)"
        return url
    }
    private func getURLForTodayWeatherRequest(location: Location) -> String {
        let locationParams = "lat=\(location.lat)&lon=\(location.lon)"
        let exclude = "&exclude=hourly,minutely,alerts"
        let apiParam = "&appid=58bd69efeab05012a439738eaf288394"
        let url = "http://api.openweathermap.org/data/2.5/onecall?\(locationParams)\(exclude)\(apiParam)"
        return url
    }
}

