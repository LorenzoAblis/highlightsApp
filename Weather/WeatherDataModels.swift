import SwiftUI

struct WeatherWidgetData: Hashable {
    let title: String
    var content: String
    let image: String
}

struct ForecastHour: Hashable {
    var time: String
    let temp: Double
    let image: String
}

struct ForecastDay: Hashable {
    var time: String
    let weathercode: String
    let image: String
    let highLow: String
    let precip: Int
}

struct CurrentWeather {
    let time: String
    let temp: Double
    let relativeHumidity: Int
    let dewpoint: Double
    let feelslike: Double
    let precip: Int
    let description: String
    let descriptionImage: String
    let wind: Double
    let uvIndex: Double
    var airQuality: Int
    var weatherWidgets: [[WeatherWidgetData]]
}
