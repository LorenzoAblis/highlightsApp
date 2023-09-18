import SwiftUI

final class DataUtils {
    func formatTime(dateString: String, startFormat: String, endFormat: String, ordinal: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = startFormat
        
        if let date = dateFormatter.date(from: dateString) {
            let formattedDateFormatter = DateFormatter()
            formattedDateFormatter.dateFormat = endFormat
            var formattedTime = formattedDateFormatter.string(from: date)
            
            if ordinal {
                switch formattedTime.suffix(2) {
                case "11", "12", "13":
                    formattedTime += "th"
                default:
                    switch formattedTime.last {
                    case "1":
                        formattedTime += "st"
                    case "2":
                        formattedTime += "nd"
                    case "3":
                        formattedTime += "rd"
                    default:
                        formattedTime += "th"
                    }
                }
            }
            return formattedTime
        }
        return ""
    }
    
    func formatWeathercode(weathercode: Int) -> String {
        switch weathercode {
        case 0:
            return "Clear Sky"
        case 1:
            return "Mainly Clear"
        case 2:
            return "Partly Cloudy"
        case 3:
            return "Cloudy"
        case 45, 48:
            return "Foggy"
        case 51:
            return "Light Drizzle"
        case 53:
            return "Moderate Drizzle"
        case 55:
            return "Heavy Drizzle"
        case 56:
            return "Light Freezing Drizzle"
        case 57:
            return "Heavy Freezing Drizzle"
        case 61:
            return "Slight Rain"
        case 63:
            return "Moderate Rain"
        case 65:
            return "Heavy Rain"
        case 66:
            return "Light Freezing Rain"
        case 67:
            return "Heavy Freezing Rain"
        case 71:
            return "Slight Snow"
        case 73:
            return "Moderate Snow"
        case 75:
            return "Heavy Snow"
        case 80:
            return "Slight Rain Showers"
        case 81:
            return "Moderate Rain Showers"
        case 82:
            return "Heavy Rain Showers"
        case 85:
            return "Slight Snow Showers"
        case 86:
            return "Heavy Snow Showers"
        default:
            return "Unknown"
        }
    }
    
    func getDescriptionImage(weathercode: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        
        let currentDate = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        
        if currentHour >= 6 && currentHour < 21 {
            switch weathercode {
            case 0:
                return "sun.max.fill"
            case 1, 2:
                return "cloud.sun.fill"
            case 3:
                return "cloud.fill"
            case 45, 48:
                return "cloud.fog.fill"
            case 51, 53, 55, 56, 57:
                return "cloud.drizzle.fill"
            case 61, 63, 65:
                return "cloud.rain.fill"
            case 66, 67:
                return "cloud.sleet.fill"
            case 71, 73, 75, 85, 86:
                return "cloud.snow.fill"
            case 80, 81, 82:
                return "cloud.heavyrain.fill"
            default:
                return "sun.max.fill"
            }
        } else {
            switch weathercode {
            case 0:
                return "moon.stars.fill"
            case 1, 2:
                return "cloud.moon.fill"
            case 3:
                return "cloud.fill"
            case 45, 48:
                return "cloud.fog.fill"
            case 51, 53, 55, 56, 57:
                return "cloud.drizzle.fill"
            case 61, 63, 65:
                return "cloud.rain.fill"
            case 66, 67:
                return "cloud.sleet.fill"
            case 71, 73, 75, 85, 86:
                return "cloud.snow.fill"
            case 80, 81, 82:
                return "cloud.heavyrain.fill"
            default:
                return "moon.stars.fill"
            }
        }
        
        
    }
}
