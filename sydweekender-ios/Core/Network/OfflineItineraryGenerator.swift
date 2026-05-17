//
//  OfflineItineraryGenerator.swift
//  sydweekender-ios
//

import Foundation

class OfflineItineraryGenerator {
    
    static func generate(date: String, groupSize: Int, interests: [String], weather: WeatherInfo) -> [ItineraryItem] {
        var items: [ItineraryItem] = []
        let db = VenueDatabase.shared
        let goodWeather = weather.isGoodForOutdoor
        
        let timeSlots = [
            "9:00 AM - 10:30 AM",
            "11:00 AM - 12:30 PM",
            "12:30 PM - 2:00 PM",
            "2:30 PM - 4:00 PM",
            "4:30 PM - 6:00 PM",
            "6:30 PM - 8:00 PM"
        ]
        
        var orderNum = 1
        
        // Always start with cafe
        let cafes = db.getVenues(byType: "cafe_hopping")
        if let cafe = db.getRandomVenue(from: cafes) {
            items.append(ItineraryItem(
                orderNumber: orderNum,
                timeSlot: timeSlots[0],
                activity: "Morning Coffee & Breakfast",
                venue: cafe,
                note: "Start your day with Sydney's amazing coffee culture!",
                transportTip: "Take the train to Central or Town Hall station."
            ))
            orderNum += 1
        }
        
        for interest in interests {
            if orderNum > 5 { break }
            
            var venues = db.getVenues(byType: interest, goodWeather: goodWeather)
            if venues.isEmpty && !goodWeather {
                venues = db.getVenues(byType: interest)
            }
            
            if let venue = db.getRandomVenue(from: venues) {
                var activity = ""
                var note = ""
                
                switch interest {
                case "hiking":
                    activity = "Scenic Walk & Nature"
                    note = goodWeather ? "Perfect weather for hiking! Bring water and sunscreen." : "Consider a shorter walk if weather turns."
                case "cafe_hopping":
                    activity = "Cafe Hopping"
                    note = "Try something different from the menu!"
                case "art_exhibitions":
                    activity = "Art & Culture"
                    note = "Check if there are any special exhibitions on!"
                case "beaches":
                    activity = "Beach Time"
                    note = goodWeather ? "Don't forget sunscreen, hat, and swimwear!" : "Maybe just enjoy the coastal views today."
                case "budget_eats":
                    activity = "Budget-Friendly Food"
                    note = "Perfect for students - delicious and affordable!"
                default:
                    activity = "Explore"
                    note = "Enjoy the experience!"
                }
                
                let slotIndex = min(orderNum - 1, timeSlots.count - 1)
                items.append(ItineraryItem(
                    orderNumber: orderNum,
                    timeSlot: timeSlots[slotIndex],
                    activity: activity,
                    venue: venue,
                    note: note,
                    transportTip: "Use Opal card for best public transport fares."
                ))
                orderNum += 1
            }
        }
        
        // Always add a lunch/dinner spot
        if orderNum <= 5 {
            let eats = db.getVenues(byType: "budget_eats")
            if let eatVenue = db.getRandomVenue(from: eats) {
                let slotIndex = min(orderNum - 1, timeSlots.count - 1)
                items.append(ItineraryItem(
                    orderNumber: orderNum,
                    timeSlot: timeSlots[slotIndex],
                    activity: "Budget-Friendly Meal",
                    venue: eatVenue,
                    note: "Delicious student-friendly food to fuel your adventure!",
                    transportTip: "Check Opal card balance for next trip."
                ))
                orderNum += 1
            }
        }
        
        return items
    }
}
