//
//  ForecastWeatherVC.swift
//  Weather
//
//  Created by Евгений Ерофеев on 30.03.22.
//

import UIKit

class ForecastWeatherViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var presenter: ForecastWeatherViewPresenterProtocol!

    private let activityIndicator = UIActivityIndicatorView()

    private lazy var noInternetView: UIView = {
        let view = gettingNoInternetView(frame: view.frame)
        return view
    }()
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ForecastTableViewCell.self, forCellReuseIdentifier: "ForecastTableViewCell")
        return tableView
    }()

    private var forecastViewModel: ForecastWeatherViewModel? {
        didSet {
            guard let forecast = forecastViewModel else { return }
            navigationItem.title = forecast.city
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = UIColor(named: "headersColor")

        tableView.dataSource = self
        tableView.delegate = self

        addViews()
        configureLayout()
        configActivityInd()
    }

    // MARK: - Constraints of table view
    private func configureLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        activityIndicator.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        activityIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }

    private func addViews() {
        view.addSubview(noInternetView)
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
    }

    // MARK: - Nubmer of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let forecast = self.forecastViewModel else { return 0 }
        return forecast.days.count
    }

    // MARK: - Number of rows in section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let forecast = self.forecastViewModel else { return 0 }
        return forecast.days[section].count
    }

    // MARK: - Height for rows
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.size.width / 6
    }

    // MARK: - Header's
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let forecast = self.forecastViewModel else { return "none" }
        var header: String
        if forecast.days[section].count < 8, section == 0 {
            header = "Today"
        } else {
            header = forecast.days[section][0].day
        }
        return header
    }

    // MARK: - Creating Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ForecastTableViewCell.identifier,
            for: indexPath
        ) as? ForecastTableViewCell
        else {
            return UITableViewCell()
        }

        guard let forecast = self.forecastViewModel else { return UITableViewCell() }
        let source = forecast.days[indexPath.section][indexPath.row]
        cell.updateWeather(
            temperature: source.temperature,
            time: source.time,
            image: UIImage(named: source.weatherIcon)!,
            description: source.weatherDescription
        )
        return cell
    }

    
    // MARK: - Deselecting row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Setup headers color
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(named: "headersColor")
    }

    // MARK: - Configuration of activity indicator
    private func configActivityInd() {
        activityIndicator.style = .large
        activityIndicator.layer.opacity = 2
        activityIndicator.backgroundColor = .systemBackground
        activityIndicator.hidesWhenStopped = true
        activityIndicator.backgroundColor = UIColor(named: "backgroundColor")
    }
}

extension ForecastWeatherViewController: ForecastWeatherViewProtocol {
    func checkedInternetConnection(connection: Bool) {
        if connection {
            tableView.isHidden = false
        } else {
            tableView.isHidden = true
        }
    }

    func succesGettingData(model: ForecastWeatherViewModel) {
        forecastViewModel = model
        tableView.reloadData()
    }

    func failureGetingData(error: Error) {
        let alert = UIAlertController(
            title: "Error",
            message: "Can't get forecast data from network",
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: "Try again",
            style: .cancel,
            handler: { _ in self.presenter.getWeather() }
        )
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        print(error.localizedDescription)
    }
    
    func gettingNoInternetView(frame: CGRect) -> UIView {
        let noIntrenetView = UIView(frame: frame)
        let label = UILabel()

        noIntrenetView.addSubview(label)

        label.frame = CGRect(x: 0, y: 0, width: noIntrenetView.frame.size.width, height: 100)
        label.center = noIntrenetView.center
        label.text = "No internet connection\nPlease turn it ON"
        label.numberOfLines = 0
        label.textAlignment = .center
        noIntrenetView.backgroundColor = UIColor(named: "backgroundColor")

        return noIntrenetView
    }

    func configureIndicator(animation: Bool) {
        if animation {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

