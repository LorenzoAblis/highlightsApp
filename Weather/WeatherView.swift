import SwiftUI
import Foundation

//https://api.open-meteo.com/v1/forecast?latitude=42.0664&longitude=-87.9373&hourly=temperature_2m&daily=weathercode,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,uv_index_max,precipitation_probability_max&temperature_unit=fahrenheit&windspeed_unit=mph&timezone=America%2FChicago

struct ContentView: View {
    @ObservedObject private var weatherDataVM = WeatherDataViewModel()
    
    var body: some View {
        ZStack {
            Color(red: 0.094, green: 0.102, blue: 0.11).edgesIgnoringSafeArea(.all)
            
            ScrollView {
                Spacer(minLength: 25)
                
                VStack {
                    Spacer(minLength: 25)
                    HStack {
                        Image(systemName: "calendar")
                            .padding(1)
                        Text(weatherDataVM.currentWeatherData.time)
                    }
                    .frame(width: 320, height: 60, alignment: .leading)
                    .font(.system(size:20, design: .rounded))
                    .shadow(color: .black, radius: 20, x: 0.0, y: 0.0)
                    Spacer(minLength: 30)
                    HStack {
                        Image(systemName: "thermometer.medium")
                        Text("\(String(format: "%.0f", weatherDataVM.currentWeatherData.temp))°F")
                    }
                    .frame(width: 340, height: 50, alignment: .leading)
                    .font(.system(size:80, design: .rounded))
                    .shadow(color: .black, radius: 50, x: 0.0, y: 0.0)
                    Text("Feels like \(String(format: "%.0f", weatherDataVM.currentWeatherData.feelslike))°")
                        .frame(width: 300, height: 70, alignment: .leading)
                        .font(.system(size:20, design: .rounded))
                    HStack {
                        if !weatherDataVM.currentWeatherData.descriptionImage.isEmpty {
                            Image(systemName: weatherDataVM.currentWeatherData.descriptionImage)
                            Text(weatherDataVM.currentWeatherData.description)
                        } else {
                            Image(systemName: "sun.max")
                        }
                    }
                    .frame(width: 320, height: 30, alignment: .leading)
                    .font(.system(size:30, design: .rounded))
                    .shadow(color: .black, radius: 50, x: 0.0, y: 0.0)
                    Spacer(minLength: 60)
                }
                .font(.system(size:25))
                .frame(width:350, height: 300)
                .background(
                    LinearGradient(colors: [
                        Color(red: 0.376, green: 0.937, blue: 1),
                        Color(red: 0, green: 0.38, blue: 1)],
                                   startPoint: .topTrailing, endPoint: .bottomLeading)
                )
                .cornerRadius(30)
                
                VStack {
                    ForEach(weatherDataVM.currentWeatherData.weatherWidgets, id:\.self) { row in
                        HStack {
                            ForEach(row, id:\.self) { widget in
                                VStack {
                                    HStack {
                                        Image(systemName: widget.image)
                                            .font(.system(size: 20))
                                    }
                                    .frame(width: 110, height: 20, alignment: .leading)
                                    Text(widget.title)
                                        .frame(width: 110, alignment: .leading)
                                    Text(widget.content)
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .frame(width: 110, alignment: .leading)
                                }
                                .modifier(WeatherWidget())
                            }
                        }
                    }
                }
                .frame(width:350)
                .padding(1)
                
                HStack {
                    ForEach(weatherDataVM.hourlyForecastData, id:\.self) { hour in
                        VStack {
                            Text(hour.time)
                                .font(.system(size: 15, design: .rounded))
                            Image(systemName: hour.image)
                                .frame(minWidth: 47, minHeight: 25)
                                .padding(1)
                            Text("\(String(format: "%.0f", hour.temp))°F")
                                .font(.system(size: 20, design: .rounded))
                        }
                        .padding(5)
                    }
                }
                .frame(width: 350, height: 125, alignment: .center)
                .background(Color(red: 0.122, green: 0.129, blue: 0.137))
                .cornerRadius(20)
                
                VStack {
                    Text("Weekly Forecast")
                        .frame(width: 320, height: 60, alignment: .leading)
                        .font(.system(size: 25, weight: .semibold, design: .rounded))
//                        .padding()
                    
                    ForEach(weatherDataVM.dailyForecastData, id:\.self) { day in
                        HStack {
                            Text(day.time)
                                .frame(width: 75, alignment: .leading)
                                .font(.system(size: 18, design: .rounded))
                            Image(systemName: day.image)
                                .frame(width: 25, alignment: .leading)
                            Text(day.highLow)
                                .frame(width: 100, alignment: .center)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            Spacer()
                            HStack {
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 20, weight: .bold))
                                Text("\(day.precip)%")
                            }
                            .frame(width: 75, alignment: .leading)
                        }
                        .frame(width: 320, height: 20)
                        .padding()
                        Divider()
                            .frame(width: 320)
                    }
                }
                .frame(width: 350)
                .background(Color(red: 0.122, green: 0.129, blue: 0.137))
                .cornerRadius(20)
            }
            .task { 
                await weatherDataVM.fetchWeatherData()
            }
        }
    }
}
