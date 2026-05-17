//
//  VenueDatabase.swift
//  sydweekender-ios
//

import Foundation

class VenueDatabase {
    static let shared = VenueDatabase()
    
    // Type -> [Venues]
    private(set) var venuesByType: [String: [Venue]] = [:]
    
    private init() {
        loadFromBundle()
    }
    
    private func loadFromBundle() {
        guard let url = Bundle.main.url(forResource: "venues", withExtension: "json") else { 
            print("Failed to find venues.json in main bundle.")
            return 
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            venuesByType = try decoder.decode([String: [Venue]].self, from: data)
            print("Successfully loaded \(venuesByType.values.flatMap { $0 }.count) venues.")
        } catch {
            print("Error loading venues.json: \(error)")
        }
    }
    
    func getVenues(byType type: String) -> [Venue] {
        return venuesByType[type] ?? []
    }
    
    // Equivalent to the Android weather fallback logic
    func getVenues(byType type: String, goodWeather: Bool) -> [Venue] {
        let all = getVenues(byType: type)
        if goodWeather {
            return all
        } else {
            return all.filter { $0.category == "indoor" }
        }
    }
    
    func getRandomVenue(from venues: [Venue]) -> Venue? {
        return venues.randomElement()
    }
}
