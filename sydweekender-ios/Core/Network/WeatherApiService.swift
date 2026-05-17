//
//  WeatherApiService.swift
//  sydweekender-ios
//

import Foundation

class WeatherApiService {
    static let sydneyLat = -33.8688
    static let sydneyLng = 151.2093
    static let baseUrl = "https://api.open-meteo.com/v1/forecast"
    
    static func fetchWeather(date: String) async throws -> WeatherInfo {
        var components = URLComponents(string: baseUrl)!
        components.queryItems = [
            URLQueryItem(name: "latitude", value: "\(sydneyLat)"),
            URLQueryItem(name: "longitude", value: "\(sydneyLng)"),
            URLQueryItem(name: "daily", value: "temperature_2m_max,temperature_2m_min,weathercode,precipitation_sum,windspeed_10m_max"),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,weathercode,windspeed_10m"),
            URLQueryItem(name: "timezone", value: "Australia/Sydney"),
            URLQueryItem(name: "start_date", value: date),
            URLQueryItem(name: "end_date", value: date)
        ]
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        // Custom decoding logic since Open-Meteo returns parallel arrays for daily
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let daily = json?["daily"] as? [String: [Any]],
              let maxTemp = (daily["temperature_2m_max"]?.first as? NSNumber)?.doubleValue,
              let minTemp = (daily["temperature_2m_min"]?.first as? NSNumber)?.doubleValue,
              let weatherCode = daily["weathercode"]?.first as? Int,
              let precipitation = (daily["precipitation_sum"]?.first as? NSNumber)?.doubleValue,
              let windSpeed = (daily["windspeed_10m_max"]?.first as? NSNumber)?.doubleValue else {
            throw URLError(.cannotParseResponse)
        }
        
        let avgTemp = (maxTemp + minTemp) / 2.0
        let description = getWeatherDescription(code: weatherCode)
        
        return WeatherInfo(
            temperature: avgTemp,
            maxTemp: maxTemp,
            minTemp: minTemp,
            weatherCode: weatherCode,
            weatherDescription: description,
            windSpeed: windSpeed,
            humidity: 50.0, // Hardcoded fallback for UI layout match
            precipitation: precipitation
        )
    }
    
    static func getWeatherDescription(code: Int) -> String {
        switch code {
        case 0: return "Clear sky"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45: return "Foggy"
        case 48: return "Depositing rime fog"
        case 51: return "Light drizzle"
        case 53: return "Moderate drizzle"
        case 55: return "Dense drizzle"
        case 56: return "Light freezing drizzle"
        case 57: return "Dense freezing drizzle"
        case 61: return "Slight rain"
        case 63: return "Moderate rain"
        case 65: return "Heavy rain"
        case 66: return "Light freezing rain"
        case 67: return "Heavy freezing rain"
        case 71: return "Slight snow"
        case 73: return "Moderate snow"
        case 75: return "Heavy snow"
        case 77: return "Snow grains"
        case 80: return "Slight rain showers"
        case 81: return "Moderate rain showers"
        case 82: return "Violent rain showers"
        case 85: return "Slight snow showers"
        case 86: return "Heavy snow showers"
        case 95: return "Thunderstorm"
        case 96: return "Thunderstorm with slight hail"
        case 99: return "Thunderstorm with heavy hail"
        default: return "Unknown weather"
        }
    }
}
