import SwiftUI
import Foundation

struct WeatherData: Decodable {
    let daily: Daily
    let hourly: Hourly
    
    struct Hourly: Decodable {
        let time: [String]
        let temperature_2m: [Double]
        let relativehumidity_2m: [Int]
        let dewpoint_2m: [Double]
        let apparent_temperature: [Double]
        let precipitation_probability: [Int]
        let weathercode: [Int]
        let windspeed_10m: [Double]
        let winddirection_10m: [Int]
        let uv_index: [Double]
    }
    
    struct Daily: Decodable {
        let time: [String]
        let weathercode: [Int]
        let temperature_2m_max: [Double]
        let temperature_2m_min: [Double]
        let apparent_temperature_max: [Double]
        let apparent_temperature_min: [Double]
        let sunrise: [String]
        let sunset: [String]
        let uv_index_max: [Double]
        let precipitation_probability_max: [Int]
    }
}

struct AirQualityData: Decodable {
    let hourly: Hourly
    
    struct Hourly: Decodable {
        let time: [String]
        let us_aqi: [Int?]
    }
}
