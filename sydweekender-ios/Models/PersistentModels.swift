//
//  PersistentModels.swift
//  sydweekender-ios
//

import Foundation
import SwiftData

/// Represents a completely saved itinerary in the history.
@Model
final class SavedItinerary {
    var title: String
    var date: String
    var groupSize: Int
    var interests: String
    var weatherSummary: String
    
    // Store JSON string of the itinerary items as SwiftData doesn't natively support complex nested generic arrays well without relationships.
    // This perfectly mirrors the Android SQLite implementation.
    var itemsJSON: String 
    
    var createdAt: Date
    
    init(title: String, date: String, groupSize: Int, interests: String, weatherSummary: String, itemsJSON: String) {
        self.title = title
        self.date = date
        self.groupSize = groupSize
        self.interests = interests
        self.weatherSummary = weatherSummary
        self.itemsJSON = itemsJSON
        self.createdAt = Date()
    }
}

/// Represents a user check-in on the map.
@Model
final class CheckInRecord {
    var venueName: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var checkInTime: Date
    
    init(venueName: String, address: String?, latitude: Double, longitude: Double) {
        self.venueName = venueName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.checkInTime = Date()
    }
}
