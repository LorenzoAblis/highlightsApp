import SwiftUI

final class WeatherViewModel: ObservableObject {
    @Published var hourlyForecastData: [ForecastHour]
    @Published var dailyForecastData: [ForecastDay]
    @Published var currentWeatherData: CurrentWeather

    let dataUtils = DataUtils()
    
    init() {
        hourlyForecastData = []
        dailyForecastData = []
        currentWeatherData = CurrentWeather(
            time: "", 
            temp: 0.0, 
            feelsLike: 0.0, 
            description: "", 
            image: "", 
            weatherWidgets: [[WeatherWidgetData(
                title: "", 
                content: "", 
                image: ""
            )]]
        )
    }
    
    func getWeatherData() async {
        guard let weatherURL = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=42.0664&longitude=-87.9373&hourly=temperature_2m,relativehumidity_2m,dewpoint_2m,apparent_temperature,precipitation_probability,weathercode,windspeed_10m,uv_index&daily=weathercode,temperature_2m_max,temperature_2m_min,precipitation_probability_max&temperature_unit=fahrenheit&windspeed_unit=mph&timezone=America%2FChicago") else {
            print("URL does not exsist")
            return
        }
        
        guard let aqiURL = URL(string: "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=42.0664&longitude=-87.9373&hourly=us_aqi&timezone=America%2FChicago") else {
            print("URL does not exist")
            return
        }
        
        do {
            let (weatherData, _) = try await URLSession.shared.data(from: weatherURL)
            let decodedWeatherData = try JSONDecoder().decode(WeatherNetworkModel.self, from: weatherData)
            
            let (aqiData, _) = try await URLSession.shared.data(from: aqiURL)
            let decodedAQIData = try JSONDecoder().decode(AQINetworkModel.self, from: aqiData)
            
            DispatchQueue.main.async {
                let timeIndex = getTimeIndex()
                
                for index in timeIndex..<min(timeIndex + 5, decodedWeatherData.hourly.time.count) {
                    let indexTime = self.dataUtils.formatTime(
                        dateString: decodedWeatherData.hourly.time[index], 
                        startFormat: "yyyy-MM-dd'T'HH:mm", 
                        endFormat: "h a", 
                        ordinal: false
                    )
                    let currentTime = self.dataUtils.formatTime(
                        dateString: decodedWeatherData.hourly.time[timeIndex], 
                        startFormat: "yyyy-MM-dd'T'HH:mm", 
                        endFormat: "h a", 
                        ordinal: false
                    )
                    
                    var forecastHour = ForecastHour(
                        time: indexTime, 
                        temp: decodedWeatherData.hourly.temperature_2m[index], 
                        image: self.dataUtils.getDescriptionImage(weathercode: decodedWeatherData.hourly.weathercode[index])
                    )
                    
                    if indexTime == currentTime {
                        forecastHour.time = "NOW"
                    }
                    
                    self.hourlyForecastData.append(forecastHour)
                }
                
                for index in 0..<decodedWeatherData.daily.time.count {
                    let indexTime = self.dataUtils.formatTime(
                        dateString: decodedWeatherData.daily.time[index], 
                        startFormat: "yyyy-MM-dd", 
                        endFormat: "EE d", 
                        ordinal: false
                    )
                    let currentTime = self.dataUtils.formatTime(
                        dateString: decodedWeatherData.hourly.time[timeIndex], 
                        startFormat: "yyyy-MM-dd'T'HH:mm", 
                        endFormat: "EE d", 
                        ordinal: false
                    )
                    
                    var forecastDay = ForecastDay(
                        time: indexTime, 
                        description: self.dataUtils.formatWeathercode(weathercode: decodedWeatherData.daily.weathercode[index]), 
                        image: self.dataUtils.getDescriptionImage(weathercode: decodedWeatherData.daily.weathercode[index]), 
                        max: decodedWeatherData.daily.temperature_2m_max[index], 
                        min: decodedWeatherData.daily.temperature_2m_min[index], 
                        precip: decodedWeatherData.daily.precipitation_probability_max[index]
                    )
                    
                    if indexTime == currentTime {
                        forecastDay.time = "Today"
                    }
                    
                    self.dailyForecastData.append(forecastDay)
                }
                
                self.currentWeatherData = CurrentWeather(
                    time: self.dataUtils.formatTime(
                        dateString: decodedWeatherData.hourly.time[timeIndex], 
                        startFormat: "yyyy-MM-dd'T'HH:mm", 
                        endFormat: "EEEE, MMMM d", 
                        ordinal: true
                    ), 
                    temp: decodedWeatherData.hourly.temperature_2m[timeIndex], 
                    feelsLike: decodedWeatherData.hourly.apparent_temperature[timeIndex], 
                    description: self.dataUtils.formatWeathercode(weathercode: decodedWeatherData.hourly.weathercode[timeIndex]), 
                    image: self.dataUtils.getDescriptionImage(weathercode: decodedWeatherData.hourly.weathercode[timeIndex]), 
                    weatherWidgets: [
                        [
                            WeatherWidgetData(
                                title: "Rain", 
                                content: "\(String(decodedWeatherData.hourly.precipitation_probability[timeIndex]))%", 
                                image: "umbrella.percent.ar"
                            ),
                            WeatherWidgetData(
                                title: "Wind", 
                                content: "\(String(format: "%.0f", decodedWeatherData.hourly.windspeed_10m[timeIndex])) mph", 
                                image: "wind"
                            ),
                            WeatherWidgetData(
                                title: "UV", 
                                content: "\(String(format: "%.0f", decodedWeatherData.hourly.uv_index[timeIndex])) of 11", 
                                image: "sun.max.fill"
                            )
                        ],
                        [
                            WeatherWidgetData(
                                title: "AQI", 
                                content: String(decodedAQIData.hourly.us_aqi[timeIndex]!), 
                                image: "aqi.medium"
                            ),
                            WeatherWidgetData(
                                title: "Humidity", 
                                content: "\(String(decodedWeatherData.hourly.relativehumidity_2m[timeIndex]))%", 
                                image: "drop"
                            ),
                            WeatherWidgetData(
                                title: "Dew", 
                                content: "\(String(format: "%.0f", decodedWeatherData.hourly.dewpoint_2m[timeIndex]))°", 
                                image: "thermometer.and.liquid.waves"
                            )
                        ]
                    ]
                )
            }
            
            @Sendable func getTimeIndex() -> Int {
                let formattedDateFormatter = DateFormatter()
                formattedDateFormatter.dateFormat = "yyyy-MM-dd'T'HH"
                
                let currentTime = formattedDateFormatter.string(from: Date())
                let formattedTimes = decodedWeatherData.hourly.time.map { time in
                    return dataUtils.formatTime(
                        dateString: time, 
                        startFormat: "yyyy-MM-dd'T'HH:mm", 
                        endFormat: "yyyy-MM-dd'T'HH", 
                        ordinal: false
                    )
                }
                
                for (index, time) in formattedTimes.enumerated() {
                    if currentTime == time {
                        return index
                    }
                }
                return -1
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
