//
//  Utility.swift
//  Weather
//
//  Created by Евгений Ерофеев on 28.03.22.
//

import UIKit

func degreeToWindDirectionConv(degree: Int) -> String {
    switch degree {
    case 0...22, 337...360 :
        return "N"
    case 23...66:
        return "NE"
    case 67...111:
        return "E"
    case 112...156:
        return "SE"
    case 157...201:
        return "S"
    case 202...246:
        return "SW"
    case 247...291:
        return "W"
    case 292...336:
        return "NW"
    default:
        return "no"
    }
}

func converterWeatherToTextFormat(weather: TodayWeatherViewModel) -> String {
    let text = """
        Today weather for \(weather.location):
        Out of doors: \(weather.tempWithDiscription)
        Probability of precipitation: \(weather.pop)
        Precipitation: \(weather.precipitation)
        Wind speed: \(weather.windSpeed)
        Wind direction: \(weather.windDirection)
        Pressure: \(weather.pressure)
        """
    return text
}

func lagWithSeconds(_ seconds: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

func notInternetView(frame: CGRect) -> UIView {
    let noInternetView = UIView(frame: frame)
    let label = UILabel()

    noInternetView.addSubview(label)

    label.frame = CGRect(x: 0, y: 0, width: noInternetView.frame.size.width, height: 110)
    label.center = noInternetView.center
    label.text = "No internet connection\n\nPlease turn it ON"
    label.numberOfLines = 0
    label.textAlignment = .center
    noInternetView.backgroundColor = UIColor(named: "backgroundColor")

    return noInternetView
}
