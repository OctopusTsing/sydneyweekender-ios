//
//  AIItineraryGenerator.swift
//  sydweekender-ios
//

import Foundation

class AIItineraryGenerator {
    
    static func generate(date: String, groupSize: Int, interests: [String], weather: WeatherInfo) async throws -> [ItineraryItem] {
        let apiKey = AppConfig.apiKey
        let baseUrlStr = AppConfig.apiUrl
        let model = AppConfig.model
        
        if apiKey.isEmpty {
            return OfflineItineraryGenerator.generate(date: date, groupSize: groupSize, interests: interests, weather: weather)
        }
        
        let prompt = buildPrompt(date: date, groupSize: groupSize, interests: interests, weather: weather)
        
        let requestBody: [String: Any] = [
            "model": model,
            "temperature": 0.7,
            "messages": [
                ["role": "system", "content": "You are a Sydney travel planner for international students. Generate practical, budget-friendly 1-day itineraries with real Sydney venues. Always respond with ONLY a JSON array, no extra text or markdown."],
                ["role": "user", "content": ONE_SHOT_USER],
                ["role": "assistant", "content": ONE_SHOT_ASSISTANT],
                ["role": "user", "content": prompt]
            ]
        ]
        
        var fullUrl = baseUrlStr
        if !fullUrl.hasSuffix("/chat/completions") {
            fullUrl = fullUrl.trimmingCharacters(in: .init(charactersIn: "/")) + "/chat/completions"
        }
        
        guard let url = URL(string: fullUrl) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown API Error"
            print("API Error: \(errorMsg)")
            throw URLError(.badServerResponse)
        }
        
        // Decode
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw URLError(.cannotParseResponse)
        }
        
        return try parseAIResponse(content: content)
    }
    
    private static func buildPrompt(date: String, groupSize: Int, interests: [String], weather: WeatherInfo) -> String {
        var prompt = "Generate a 1-day Sydney weekend itinerary for a group of \(groupSize).\n"
        prompt += "Travel date: \(date)\n"
        prompt += "Interests: \(interests.joined(separator: ", "))\n"
        prompt += "Weather: \(weather.weatherDescription), \(Int(weather.maxTemp))°C max, \(Int(weather.minTemp))°C min"
        if weather.precipitation > 0 {
            prompt += ", precipitation: \(String(format: "%.1f", weather.precipitation))mm"
        }
        prompt += "\n\nWeather is \(weather.isGoodForOutdoor ? "good" : "not ideal") for outdoor activities.\n"
        return prompt
    }
    
    private static func parseAIResponse(content: String) throws -> [ItineraryItem] {
        var cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("```") {
            if let firstNewline = cleaned.firstIndex(of: "\n"),
               let lastFence = cleaned.range(of: "```", options: .backwards) {
                cleaned = String(cleaned[cleaned.index(after: firstNewline)..<lastFence.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        if let start = cleaned.firstIndex(of: "["), let end = cleaned.lastIndex(of: "]") {
            cleaned = String(cleaned[start...end])
        }
        
        guard let data = cleaned.data(using: .utf8) else { throw URLError(.cannotDecodeContentData) }
        let decoder = JSONDecoder()
        return try decoder.decode([ItineraryItem].self, from: data)
    }
    
    static let ONE_SHOT_USER = """
    Generate a 1-day Sydney weekend itinerary for a group of 1.
    Travel date: 2025-07-12
    Interests: beaches, budget_eats
    Weather: Clear sky, 26°C max, 18°C min
    Weather is good for outdoor activities.
    """
    
    static let ONE_SHOT_ASSISTANT = """
    [
      {
        "orderNumber": 1,
        "timeSlot": "9:00 AM - 10:00 AM",
        "activity": "Morning Coffee & Breakfast",
        "venue": {
            "name": "Bills Darlinghurst",
            "address": "359 Crown St, Darlinghurst",
            "description": "Iconic Sydney cafe famous for ricotta hotcakes.",
            "budgetRange": "$$"
        },
        "note": "Arrive early to avoid the brunch rush!",
        "transportTip": "Take the train to Kings Cross station, then walk 5 min."
      },
      {
        "orderNumber": 2,
        "timeSlot": "10:30 AM - 1:00 PM",
        "activity": "Beach Time",
        "venue": {
            "name": "Bondi Beach",
            "address": "Bondi Beach, NSW",
            "description": "Australia's most famous beach. Great for swimming and surfing.",
            "budgetRange": "Free"
        },
        "note": "Apply sunscreen every 2 hours. The south end is less crowded.",
        "transportTip": "Take bus 333 from Circular Quay directly to Bondi Beach."
      }
    ]
    """
}
