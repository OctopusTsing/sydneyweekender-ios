//
//  Models.swift
//  sydweekender-ios
//

import Foundation

/// Represents a venue to visit. Matches venues.json and AI response.
struct Venue: Codable, Hashable {
    var name: String
    var type: String?
    var category: String?
    var description: String?
    var address: String?
    var latitude: Double?
    var longitude: Double?
    var budgetRange: String?
    var openingHours: String?
}

/// Represents a single stop in the itinerary. Matches the AI JSON structure.
struct ItineraryItem: Codable, Identifiable, Hashable {
    var id: UUID { UUID() } // Automatically generated for SwiftUI Lists
    var orderNumber: Int
    var timeSlot: String
    var activity: String
    var venue: Venue
    var note: String?
    var transportTip: String?
    var isCheckedIn: Bool = false
    
    // Custom CodingKeys to ignore 'id' and 'isCheckedIn' during JSON decoding from AI
    enum CodingKeys: String, CodingKey {
        case orderNumber, timeSlot, activity, venue, note, transportTip
    }
}

/// Weather data model mapped from Open-Meteo
struct WeatherInfo: Codable {
    var temperature: Double
    var maxTemp: Double
    var minTemp: Double
    var weatherCode: Int
    var weatherDescription: String
    var windSpeed: Double
    var humidity: Double
    var precipitation: Double
    
    var isGoodForOutdoor: Bool {
        // WMO codes logic identical to Android
        if weatherCode >= 51 && weatherCode <= 99 { return false }
        if precipitation > 2.0 { return false }
        if windSpeed > 50.0 { return false }
        return true
    }
    
    var clothingRecommendation: String {
        var rec = ""
        if maxTemp >= 30 {
            rec += "☀️ Hot day! Wear light clothes, hat, sunscreen.\n"
        } else if maxTemp >= 22 {
            rec += "🌤️ Warm and pleasant. T-shirt, shorts.\n"
        } else if maxTemp >= 15 {
            rec += "🌥️ Mild temperature. Bring a light jacket.\n"
        } else {
            rec += "🧥 Cool day. Wear layers.\n"
        }
        
        if precipitation > 0 || weatherCode >= 51 {
            rec += "🌧️ Bring an umbrella!"
        } else if isGoodForOutdoor {
            rec += "😎 Great weather for outdoor activities!"
        }
        return rec
    }
}
