import SwiftUI
import Foundation

//https://api.open-meteo.com/v1/forecast?latitude=42.0664&longitude=-87.9373&hourly=temperature_2m,relativehumidity_2m,dewpoint_2m,apparent_temperature,precipitation_probability,weathercode,visibility,windspeed_10m,winddirection_10m,uv_index&daily=weathercode,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,uv_index_max,precipitation_probability_max&temperature_unit=fahrenheit&windspeed_unit=mph&timezone=America%2FChicago

// https://shorturl.at/actyK

final class WeatherDataViewModel: ObservableObject {
    @Published var dailyForecastData: [ForecastDay] = []
    @Published var hourlyForecastData: [ForecastHour] = []
    @Published var currentWeatherData: CurrentWeather = CurrentWeather(time: "", temp: 0.0, relativeHumidity: 0, dewpoint: 0.0, feelslike: 0.0, precip: 0, description: "", descriptionImage: "", wind: 0.0, uvIndex: 0.0, airQuality: 0, weatherWidgets: [])
    
    let dataFormatter = DataFormatter()
    
    func fetchWeatherData() async {
        if let weatherUrl = URL(string: "https://shorturl.at/actyK") {
            do {
                let (data, _) = try await URLSession.shared.data(from: weatherUrl)
                let decodedResponse = try await JSONDecoder().decode(WeatherData.self, from: data)
                let timeIndex = getTimeIndex()
                
                for index in timeIndex..<min(timeIndex + 5, decodedResponse.hourly.time.count) {
                    let indexTime = dataFormatter.formatTime(dateString: decodedResponse.hourly.time[index], startFormat: "yyyy-MM-dd'T'HH:mm", endFormat: "h a", ordinal: false)
                    let currentTime = dataFormatter.formatTime(dateString: decodedResponse.hourly.time[timeIndex], startFormat: "yyyy-MM-dd'T'HH:mm", endFormat: "h a", ordinal: false)
                    
                    var forecastHour = ForecastHour(
                        time: indexTime,
                        temp: decodedResponse.hourly.temperature_2m[index], 
                        image: dataFormatter.getDescriptionImage(weathercode: decodedResponse.hourly.weathercode[index]))
                    
                    if indexTime == currentTime {
                        forecastHour.time = "NOW"
                    }
                    
                    hourlyForecastData.append(forecastHour)
                }
                
                for index in 0..<decodedResponse.daily.time.count {
                    let indexTime = dataFormatter.formatTime(dateString: decodedResponse.daily.time[index], startFormat: "yyyy-MM-dd", endFormat: "EE d", ordinal: false)
                    let currentTime = dataFormatter.formatTime(dateString: decodedResponse.hourly.time[timeIndex], startFormat: "yyyy-MM-dd'T'HH:mm", endFormat: "EE d", ordinal: false)
                    
                    var forecastDay = ForecastDay(
                        time: indexTime, 
                        weathercode: dataFormatter.formatWeathercode(weathercode: decodedResponse.daily.weathercode[index]),
                        image: dataFormatter.getDescriptionImage(weathercode: decodedResponse.daily.weathercode[index]),
                        highLow: "\(String(format: "%.0f", decodedResponse.daily.temperature_2m_max[index]))° / \(String(format: "%.0f", decodedResponse.daily.temperature_2m_min[index]))°", 
                        precip: decodedResponse.daily.precipitation_probability_max[index])
                    
                    if indexTime == currentTime {
                        forecastDay.time = "Today"
                    }
                    
                    dailyForecastData.append(forecastDay)
                }
                
                currentWeatherData = CurrentWeather(
                    time: dataFormatter.formatTime(dateString: decodedResponse.hourly.time[timeIndex], startFormat: "yyyy-MM-dd'T'HH:mm", endFormat: "EEEE, MMMM d", ordinal: true), 
                    temp: decodedResponse.hourly.temperature_2m[timeIndex], 
                    relativeHumidity: decodedResponse.hourly.relativehumidity_2m[timeIndex], 
                    dewpoint: decodedResponse.hourly.dewpoint_2m[timeIndex], 
                    feelslike: decodedResponse.hourly.apparent_temperature[timeIndex], 
                    precip: decodedResponse.hourly.precipitation_probability[timeIndex], 
                    description: dataFormatter.formatWeathercode(weathercode: decodedResponse.hourly.weathercode[timeIndex]),
                    descriptionImage: dataFormatter.getDescriptionImage(weathercode: decodedResponse.hourly.weathercode[timeIndex]),
                    wind: decodedResponse.hourly.windspeed_10m[timeIndex],
                    uvIndex: decodedResponse.hourly.uv_index[timeIndex],
                    airQuality: 0,
                    weatherWidgets: [
                        [
                            WeatherWidgetData(title: "Rain", content: "\(decodedResponse.hourly.precipitation_probability[timeIndex])%", image: "umbrella.percent.ar"),
                            WeatherWidgetData(title: "Wind", content: "\(String(format: "%.0f", decodedResponse.hourly.windspeed_10m[timeIndex])) mph", image: "wind"),
                            WeatherWidgetData(title: "UV", content: "\(String(format: "%.0f", decodedResponse.hourly.uv_index[timeIndex])) of 11", image: "sun.max.fill")
                        ],
                        [
                            WeatherWidgetData(title: "AQI", content: "\(decodedResponse.hourly.precipitation_probability[timeIndex])%", image: "aqi.medium"),
                            WeatherWidgetData(title: "Humidity", content: "\(decodedResponse.hourly.relativehumidity_2m[timeIndex])%", image: "drop"),
                            WeatherWidgetData(title: "Dew", content: "\(String(format: "%.0f", decodedResponse.hourly.dewpoint_2m[timeIndex]))°", image: "thermometer.and.liquid.waves")
                        ]
                    ]
                )
                
                func getTimeIndex() -> Int {
                    let formattedDateFormatter = DateFormatter()
                    formattedDateFormatter.dateFormat = "yyyy-MM-dd'T'HH"
                    
                    let currentTime = formattedDateFormatter.string(from: Date())
                    
                    let formattedTimes = decodedResponse.hourly.time.map { time in
                        return dataFormatter.formatTime(dateString: time, 
                                                        startFormat: "yyyy-MM-dd'T'HH:mm", 
                                                        endFormat: "yyyy-MM-dd'T'HH", 
                                                        ordinal: false)
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
        
        if let aqiUrl = URL(string: "https://air-quality-api.open-meteo.com/v1/air-quality?latitude=42.0664&longitude=-87.9373&hourly=us_aqi&timezone=America%2FChicago&domains=cams_global") {
            do {
                let (data, _) = try await URLSession.shared.data(from: aqiUrl)
                let decodedResponse = try await JSONDecoder().decode(AirQualityData.self, from: data)
                
                func getTimeIndex() -> Int {
                    let formattedDateFormatter = DateFormatter()
                    formattedDateFormatter.dateFormat = "yyyy-MM-dd'T'HH"
                    
                    let currentTime = formattedDateFormatter.string(from: Date())
                    
                    let formattedTimes = decodedResponse.hourly.time.map { time in
                        return dataFormatter.formatTime(dateString: time, 
                                                        startFormat: "yyyy-MM-dd'T'HH:mm", 
                                                        endFormat: "yyyy-MM-dd'T'HH", 
                                                        ordinal: false)
                    }
                    
                    for (index, time) in formattedTimes.enumerated() {
                        if currentTime == time {
                            return index
                        }
                    }
                    
                    return -1
                }
                
                let timeIndex = getTimeIndex()
                
                currentWeatherData.weatherWidgets[1][0].content = "\(decodedResponse.hourly.us_aqi[timeIndex]!)"
                
            } catch {
                print(error)
            }
        }
    }
}

