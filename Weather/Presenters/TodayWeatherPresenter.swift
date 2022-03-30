//
//  TodayWeatherPresenter.swift
//  Weather
//
//  Created by Евгений Ерофеев on 30.03.22.
//

import UIKit
import Network

protocol TodayWeatherViewProtocol: AnyObject {
    func checkingInternetConnection(connection: Bool)
    func successGettingData(model: TodayWeatherViewModel)
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
    
    var todayWeatherForView: TodayWeatherViewModel? = TodayWeatherViewModel(
        windSpeed: "",
        windDirection: "",
        icon: "",
        pressure: "",
        precipitation: "",
        precipitayionIcon: "",
        pop: "",
        location: "",
        tempWithDescription: "")
    
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
            guard let self = self else { return }
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    self.getWeather()
                    self.view?.checkingInternetConnection(connection: true)
                }
                print("Internet connection ON.")
            } else {
                DispatchQueue.main.async {
                    self.view?.checkingInternetConnection(connection: false)
                }
                print("NO Internet connection.")
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
            request: .forecast) {
                [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let todayLocation):
                        self.todayLocation = todayLocation
                        group.leave()
                    case .failure(let error):
                        print(error.localizedDescription)
                        group.notify(queue: .main) {
                            self.view?.failureGettingData()
                        }
                    }
                }
            }
        group.enter()
        networkService.getWeather(
            for: TodayWeather.self,
            location: location,
            request: .today) {
                [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let todayWeather):
                        self.todayWeather = todayWeather
                        group.leave()
                    case .failure(let error):
                        print(error.localizedDescription)
                        group.notify(queue: .main) {
                            self.view?.failureGettingData()
                        }
                    }
                }
            }
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            guard let todayWeather = self.todayWeather else { return }
            guard let todayLocation = self.todayLocation else { return }
            self.view?.successGettingData(
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
        let windDirection = degreeToWindDirectionConv(degree: todayWeather.today.windDeg)
        
        let precipitation = { ()-> [String] in
            var precipitation = [String]()
            if let rain = todayWeather.daily[0].rain {
                precipitation.append("\(rain)mm")
                precipitation.append("drop")
            } else if let snow = todayWeather.daily[0].snow {
                precipitation.append("\(snow)mm")
                precipitation.append("snow")
            } else {
                precipitation = ["0", "drop"]
            }
            return precipitation
        }()
        
        let todayWeatherForView = TodayWeatherViewModel(
            windSpeed: "\(todayWeather.today.windSpeed)m/s",
            windDirection: windDirection,
            icon: todayWeather.today.weather[0].icon,
            pressure: "\(todayWeather.today.pressure)hPA",
            precipitation: precipitation[0],
            precipitayionIcon: precipitation[1],
            pop: "\(Int(todayWeather.daily[0].pop * 100))%",
            location: "\(self.todayLocation?.city.name ?? "") \(self.todayLocation?.city.country ?? "")",
            tempWithDescription: "\(Int(todayWeather.today.temp - 273))°C - \(todayWeather.today.weather[0].weatherDescription)")
        return todayWeatherForView
    }
    
    @objc func share() {
        guard let todayWeather = self.todayWeather else {
            return
        }
        guard let todayLocation = self.todayLocation else {
            return
        }
        let message = converterWeatherToTextFormat(weather:
            configureViewModel(todayWeather: todayWeather,
                               todayLocation: todayLocation)
        )
        let thingsToShare = [message] as [Any]
        let activVC = UIActivityViewController(activityItems: thingsToShare,
                                                  applicationActivities: nil)
        self.view?.present(activityVC: activVC)
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
}
