//
//  ForecastWeatherPresenter.swift
//  Weather
//
//  Created by Евгений Ерофеев on 30.03.22.
//

import Foundation
import Network

protocol ForecastWeatherViewProtocol: AnyObject {
    func checkedInternetConnection(connection: Bool)
    func succesGettingData(model: ForecastWeatherViewModel)
    func failureGetingData(error: Error)
    func configureIndicator(animation: Bool)
}

protocol ForecastWeatherViewPresenterProtocol: AnyObject {
    init(view: ForecastWeatherViewProtocol, networkService: NetworkService)
    func getWeather()
    var forecastForView: ForecastWeatherViewModel? { get set }
    var location: Location? { get set }
}

class ForecastWeatherPresenter: ForecastWeatherViewPresenterProtocol {
    weak var view: ForecastWeatherViewProtocol?
    
    private var networkService = NetworkService()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    
    var forecastForView: ForecastWeatherViewModel?
    
    private let locationService = LocationService()
    
    var location: Location? {
        didSet {
            monitor.start(queue: queue)
        }
    }
    
    required init(view: ForecastWeatherViewProtocol, networkService: NetworkService) {
        self.view = view
        
        self.networkService = networkService
        
        self.locationService.delegate = self
        
        self.locationService.requestLocation()
        
        self.view?.configureIndicator(animation: true)
        
        // Checking internet connection
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.getWeather()
                    self.view?.checkedInternetConnection(connection: true)
                }
                print("Internet connection is ON")
            } else {
                self.view?.checkedInternetConnection(connection: false)
                self.view?.configureIndicator(animation: false)
                print("NO internet connection.")
            }
        }
    }
    
    // Getting information from OpenWeatherMap
    func getWeather() {
        self.view?.configureIndicator(animation: true)
        
        guard let location = self.location else { return }
        
        networkService.getWeather(
            for: ForecastWeather.self,
            location: location,
            request: .forecast) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let forecastWeather):
                        self.view?.succesGettingData(
                            model: self.prepareToView(
                                forecast: forecastWeather!
                            )
                        )
                        self.locationService.stopUpdatingLocation()
                        self.view?.configureIndicator(animation: false)
                        self.monitor.cancel()
                    case .failure(let error):
                        self.view?.failureGetingData(error: error)
                    }
                }
            }
    }
    
    // Prepare APImodel to view
    private func prepareToView(forecast: ForecastWeather) -> ForecastWeatherViewModel {
        let dateFormatterForHours = DateFormatter()
        dateFormatterForHours.dateFormat = "HH:mm"
        
        let dateFormatterForDays = DateFormatter()
        dateFormatterForDays.dateFormat = "EEEE"
        
        var daysArray = [ForecastWeatherViewModel.Day]()
        
        for day in forecast.list {
            let date = Date(timeIntervalSince1970: Double(day.dt))
            daysArray.append(
                ForecastWeatherViewModel.Day(
                    day: dateFormatterForDays.string(from: date),
                    temperature: Int(day.main.temp - 273),
                    time: dateFormatterForHours.string(from: date),
                    weatherDescription: day.weather[0].description,
                    weatherIcon: day.weather[0].icon
                )
            )
        }
        let forecastForView = ForecastWeatherViewModel(
            days: groupedForecast(forecast: daysArray),
            city: forecast.city.name
        )
        return forecastForView
    }
    
    // Transform hours forecast to days forecast
    private func groupedForecast(forecast: [ForecastWeatherViewModel.Day]) -> [[ForecastWeatherViewModel.Day]] {
        var previousDay = forecast[0]
        var arryayOfDays = [ForecastWeatherViewModel.Day]()
        var groupedDays = [[ForecastWeatherViewModel.Day]]()
        for day in forecast {
            if previousDay.day != day.day {
                previousDay = day
                groupedDays.append(arryayOfDays)
                arryayOfDays = []
            }
            arryayOfDays.append(day)
        }
        groupedDays.append(arryayOfDays)
        return groupedDays
    }
}

extension ForecastWeatherPresenter: LocationServiceDelegate {
    func didUpdateLocation(location: Location) {
        self.location = location
    }
    
    func didntUpdateLocation() {
        self.locationService.requestLocation()
    }
    
    func locationIsDisabled() {
        self.view?.configureIndicator(animation: true)
    }
}
