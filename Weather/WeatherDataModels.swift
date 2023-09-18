import SwiftUI

struct ForecastHour: Hashable {
    var time: String
    var temp: Double
    var image: String
}

struct ForecastDay: Hashable {
    var time: String
    var description: String
    var image: String
    var max: Double
    var min: Double
    var precip: Int
}

struct WeatherWidgetData: Hashable {
    var title: String
    var content: String
    var image: String
}

struct CurrentWeather {
    var time: String
    var temp: Double
    var feelsLike: Double
    var description: String
    var image: String
    var weatherWidgets: [[WeatherWidgetData]]
}
