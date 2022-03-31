//
//  Builder.swift
//  Weather
//
//  Created by Евгений Ерофеев on 30.03.22.
//

import UIKit

protocol Builder {
    static func createTodayWeatherModule() -> UIViewController
    static func createForecastWeatherModule() -> UIViewController
}

class ModulBuilder: Builder {
    static func createTodayWeatherModule() -> UIViewController {
        let view = TodayWeatherVC()
        let networkService = NetworkService()
        let presenter = TodayWeatherPresenter(view: view, networkService: networkService)
        view.presenter = presenter
        return view
    }
    
    static func createForecastWeatherModule() -> UIViewController {
        let view = ForecastWeatherViewController()
        let networkService = NetworkService()
        let presenter = ForecastWeatherPresenter(view: view, networkService: networkService)
        view.presenter = presenter
        return view
    }
}

