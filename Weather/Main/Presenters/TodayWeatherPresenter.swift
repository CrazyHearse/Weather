//
//  TodayWeatherPresenter.swift
//  Weather
//
//  Created by Евгений Ерофеев on 30.03.22.
//

import UIKit
import Network

protocol TodayWeatherViewProtocol: AnyObject {
    func succesGettingData(model: TodayWeatherViewModel)
    func checkedInternetConnection(connection: Bool)
    func present(activityVC: UIActivityViewController)
    func failureGettingData()
    func failureGettingLocation()
    func locationIsDisabled()
    func configureIndicator(animation: Bool)
}

protocol TodayWeatherViewPresenterProtocol: AnyObject {
    init(view: TodayWeatherViewProtocol, networkService: NetworkService)
    func getWeather()
    func share()
    var todayWeatherForView: TodayWeatherViewModel? { get set }
    var location: Location? { get set }
}

class TodayWeatherPresenter: TodayWeatherViewPresenterProtocol {
    weak var view: TodayWeatherViewProtocol?
    
    private var networkService = NetworkService()
    
    let locationService = LocationService()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    
    private var todayWeather: TodayWeather?
    private var todayLocation: LocationApi?
    
    var todayWeatherForView: TodayWeatherViewModel?
    
    var location: Location? {
        didSet {
            monitor.start(queue: queue)
        }
    }
    
    required init(view: TodayWeatherViewProtocol, networkService: NetworkService) {
        self.view = view
        self.networkService = networkService
        self.locationService.delegate = self
        self.locationService.requestLocation()
        
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self?.getWeather()
                    self?.view?.checkedInternetConnection(connection: true)
                }
                print("Internet connection is ON")
            } else {
                DispatchQueue.main.async {
                    self?.view?.checkedInternetConnection(connection: false)
                }
                print("NO internet connection.")
            }
        }
    }
    
    func getWeather() {
        self.view?.configureIndicator(animation: true)
        
        guard let location = location else { return }
        let group = DispatchGroup()
        group.enter()
        networkService.getWeather(
            for: LocationApi.self,
            location: location,
            request: .forecast
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let todayLocation):
                    self?.todayLocation = todayLocation
                    group.leave()
                case .failure(let error):
                    print(error.localizedDescription)
                    group.notify(queue: .main) {
                        self?.view?.failureGettingData()
                    }
                }
            }
        }
        group.enter()
        networkService.getWeather(
            for: TodayWeather.self,
            location: location,
            request: .current
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let todayWeather):
                    self?.todayWeather = todayWeather
                    group.leave()
                case .failure(let error):
                    print(error.localizedDescription)
                    group.notify(queue: .main) {
                        self?.view?.failureGettingData()
                    }
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            guard let todayWeather = self.todayWeather else { return }
            guard let todayLocation = self.todayLocation else { return }
            self.view?.succesGettingData(
                model: self.configureViewModel(
                    todayWeather: todayWeather,
                    todayLocation: todayLocation
                )
            )
            self.view?.configureIndicator(animation: false)
            self.locationService.stopUpdatingLocation()
            self.monitor.cancel()
        }
    }
    
    private func configureViewModel(todayWeather: TodayWeather, todayLocation: LocationApi) -> TodayWeatherViewModel {
        let windDirection = degreeToDirectionsConverting(degree: todayWeather.current.windDeg)
        
        let precipitation = { ()-> [ String ] in
            var precipitation = [String]()
            if let snow = todayWeather.daily[0].snow {
                precipitation.append("\(snow)mm")
                precipitation.append("snow")
            } else if let rain = todayWeather.daily[0].rain {
                precipitation.append("\(rain)mm")
                precipitation.append("drop")
            } else {
                precipitation = ["0", "drop"]
            }
            return precipitation
        }()
        
        let todayWeatherForView = TodayWeatherViewModel(
            location: "\(self.todayLocation?.city.name ?? "") \(self.todayLocation?.city.country ?? "")",
            tempWithDescription:
                "\(Int(todayWeather.current.temp - 273))°C | \(todayWeather.current.weather[0].weatherDescription)",
            pop: "\(Int(todayWeather.daily[0].pop * 100))%",
            precipitation: precipitation[0],
            precipitationIcon: precipitation[1],
            pressure: "\(todayWeather.current.pressure)hPa",
            windSpeed: "\(todayWeather.current.windSpeed)m/s",
            windDirection: windDirection,
            icon: todayWeather.current.weather[0].icon
        )
        return todayWeatherForView
    }
    
    @objc func share() {
        guard let todayWeather = self.todayWeather else { return }
        guard let todayLocation = self.todayLocation else { return }
        
        let message = transformerFromWeatherToText(weather:
                                                    configureViewModel(
                                                        todayWeather: todayWeather,
                                                        todayLocation: todayLocation
                                                    )
        )
        let objectsToShare = [message] as [Any]
        let activityVC = UIActivityViewController(
            activityItems: objectsToShare,
            applicationActivities: nil
        )
        self.view?.present(activityVC: activityVC)
    }
}

extension TodayWeatherPresenter: LocationServiceDelegate {
    func locationIsDisabled() {
        self.view?.locationIsDisabled()
    }
    
    func didUpdateLocation(location: Location) {
        self.location = location
    }
    
    func didntUpdateLocation() {
        self.view?.failureGettingLocation()
    }
    
    func transformerFromWeatherToText(weather: TodayWeatherViewModel) -> String {
        let text = """
            Actual weather for \(weather.location):
            Outdoor weather: \(weather.tempWithDescription)
            Probability of precipitation: \(weather.pop)
            Precipitation: \(weather.precipitation)mm
            Pressure: \(weather.pressure)
            Wind speed: \(weather.windSpeed)
            Wind direction: \(weather.windDirection)
            """
        return text
    }
    
    func degreeToDirectionsConverting(degree: Int) -> String {
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
            return "none"
        }
    }
}
