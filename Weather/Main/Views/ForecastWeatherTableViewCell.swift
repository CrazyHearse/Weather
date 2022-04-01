//
//  ForecastWeatherTableViewCell.swift
//  Weather
//
//  Created by Евгений Ерофеев on 30.03.22.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    static let identifier = "ForecastTableViewCell"
    
    private let weatherImage = UIImageView()
    
    private let timeLabel = UILabel()
    private let weatherDescriptionLabel = UILabel()
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.font = .systemFont(ofSize: 60)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.25
        label.numberOfLines = 0
        label.baselineAdjustment = .alignCenters
        label.textAlignment  = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = UIColor(named: "backgroundColor")
        
        [
            timeLabel,
            temperatureLabel,
            weatherImage,
            weatherDescriptionLabel
        ].forEach( { contentView.addSubview($0) } )
    }
    
    required init?(coder: NSCoder) {
        fatalError("super.init(coder: coder)")
    }
    
    public func updateWeather(temperature: Int, time: String, image: UIImage, description: String) {
        temperatureLabel.text = "\(temperature)°"
        timeLabel.text = time
        weatherImage.image = image
        weatherDescriptionLabel.text = description
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        temperatureLabel.text = nil
        timeLabel.text = nil
        imageView?.image = nil
        weatherDescriptionLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutItemsInCell()
    }
    
    private func layoutItemsInCell() {
        let elementSize = contentView.frame.size.height - 12
        
        [
            weatherImage,
            temperatureLabel,
            timeLabel,
            weatherDescriptionLabel
        ].forEach( { $0?.translatesAutoresizingMaskIntoConstraints = false } )
        
        contentView.addConstraints(
            [
                weatherImage.widthAnchor.constraint(equalToConstant: elementSize),
                weatherImage.heightAnchor.constraint(equalToConstant: elementSize),
                weatherImage.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 12
                ),
                weatherImage.topAnchor.constraint(
                    equalTo: contentView.topAnchor,
                    constant: 6
                ),
                temperatureLabel.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: contentView.frame.size.width - 1.5 * elementSize - 12
                ),
                temperatureLabel.topAnchor.constraint(
                    equalTo: contentView.topAnchor,
                    constant: 6
                ),
                temperatureLabel.widthAnchor.constraint(equalToConstant: 1.5 * elementSize),
                temperatureLabel.heightAnchor.constraint(equalToConstant: elementSize),
                timeLabel.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: elementSize + 32
                ),
                timeLabel.topAnchor.constraint(
                    equalTo: contentView.topAnchor,
                    constant: 6
                ),
                timeLabel.widthAnchor.constraint(
                    equalToConstant: contentView.frame.size.width - 2.5 * elementSize - 42
                ),
                timeLabel.heightAnchor.constraint(equalToConstant: elementSize / 2),
                weatherDescriptionLabel.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: elementSize + 32
                ),
                weatherDescriptionLabel.topAnchor.constraint(
                    equalTo: contentView.topAnchor,
                    constant: elementSize / 2 + 6
                ),
                weatherDescriptionLabel.widthAnchor.constraint(
                    equalToConstant: contentView.frame.size.width - 2.5 * elementSize - 42
                ),
                weatherDescriptionLabel.heightAnchor.constraint(equalToConstant: elementSize / 2)
            ]
        )
    }
}

