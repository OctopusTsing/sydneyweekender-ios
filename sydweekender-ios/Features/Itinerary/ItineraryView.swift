//
//  ItineraryView.swift
//  sydweekender-ios
//

import SwiftUI
import SwiftData

struct ItineraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var existingRecords: [CheckInRecord]
    
    let date: Date
    let groupSize: Int
    let interests: [String]
    
    @State private var weatherInfo: WeatherInfo?
    @State private var items: [ItineraryItem] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var isSaved = false
    
    var body: some View {
        ZStack {
            Color.Design.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(Color.Design.primary)
                            .scaleEffect(1.5)
                        Text("Creating magic...")
                            .foregroundColor(Color.Design.textSub)
                            .padding(.top, 16)
                        Spacer()
                    }
                } else if let errorMessage = errorMessage {
                    VStack {
                        Spacer()
                        Text("Failed to generate")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Weather Card
                            if let weather = weatherInfo {
                                HStack {
                                    Text("☀️")
                                        .font(.system(size: 32))
                                    Text("\(weather.weatherDescription) | \(Int(weather.maxTemp))°C. \(weather.clothingRecommendation)")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.Design.textMain)
                                        .padding(.leading, 8)
                                    Spacer()
                                }
                                .padding()
                                .background(Color.Design.cardBackground)
                                .cornerRadius(24)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            
                            // Timeline
                            ForEach(items.indices, id: \.self) { index in
                                ItineraryItemRow(item: $items[index], isFirst: index == 0, isLast: index == items.count - 1)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 100)
                    }
                }
            }
            
            if !isLoading && errorMessage == nil {
                VStack {
                    Spacer()
                    Button(action: saveItinerary) {
                        Text(isSaved ? "✅ SAVED!" : "SAVE ITINERARY")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isSaved ? Color.Design.accentGreen : Color.Design.primary)
                            .cornerRadius(28)
                    }
                    .disabled(isSaved)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("Your Itinerary")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await generateItinerary()
        }
    }
    
    private func generateItinerary() async {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        
        do {
            let weather = try await WeatherApiService.fetchWeather(date: dateStr)
            self.weatherInfo = weather
            
            let result = try await AIItineraryGenerator.generate(date: dateStr, groupSize: groupSize, interests: interests, weather: weather)
            
            // Sync check-in state with footprint
            var syncedItems = result
            for i in 0..<syncedItems.count {
                if existingRecords.contains(where: { $0.venueName == syncedItems[i].venue.name }) {
                    syncedItems[i].isCheckedIn = true
                }
            }
            
            self.items = syncedItems
            self.isLoading = false
            
        } catch {
            print("Generation Error: \(error)")
            // Fallback for weather failure
            let fallbackWeather = WeatherInfo(temperature: 22.0, maxTemp: 25.0, minTemp: 19.0, weatherCode: 2, weatherDescription: "Partly cloudy", windSpeed: 15.0, humidity: 60.0, precipitation: 0.0)
            self.weatherInfo = fallbackWeather
            
            do {
                let result = try await AIItineraryGenerator.generate(date: dateStr, groupSize: groupSize, interests: interests, weather: fallbackWeather)
                
                // Sync check-in state with footprint
                var syncedItems = result
                for i in 0..<syncedItems.count {
                    if existingRecords.contains(where: { $0.venueName == syncedItems[i].venue.name }) {
                        syncedItems[i].isCheckedIn = true
                    }
                }
                
                self.items = syncedItems
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func saveItinerary() {
        guard !isSaved else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        
        let interestStr = interests.joined(separator: ", ")
        let weatherStr = weatherInfo?.weatherDescription ?? "N/A"
        let title = "\(dateStr) - \(interestStr)"
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            let jsonString = String(data: data, encoding: .utf8) ?? "[]"
            
            let saved = SavedItinerary(
                title: title,
                date: dateStr,
                groupSize: groupSize,
                interests: interestStr,
                weatherSummary: weatherStr,
                itemsJSON: jsonString
            )
            
            modelContext.insert(saved)
            isSaved = true
        } catch {
            print("Failed to save: \(error)")
        }
    }
}

struct ItineraryItemRow: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var item: ItineraryItem
    let isFirst: Bool
    let isLast: Bool
    
    @Query private var existingRecords: [CheckInRecord]
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline
            VStack {
                Rectangle()
                    .fill(isFirst ? Color.clear : Color.Design.border)
                    .frame(width: 1, height: 16)
                
                Text("\(item.orderNumber)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(Color.Design.accentOrange)
                    .clipShape(Circle())
                
                Rectangle()
                    .fill(isLast ? Color.clear : Color.Design.border)
                    .frame(width: 1)
            }
            .frame(width: 40)
            
            // Content Card
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.timeSlot)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.Design.textSub)
                    Spacer()
                }
                
                Text(item.activity)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(Color.Design.textMain)
                
                Text(item.venue.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color.Design.accentGreen)
                
                if let address = item.venue.address {
                    Text("📍 \(address)")
                        .font(.system(size: 12))
                        .foregroundColor(Color.Design.textSub)
                }
                
                if let budget = item.venue.budgetRange {
                    Text(budget)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.Design.textMain)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#F0F4F0"))
                        .cornerRadius(12)
                }
                
                if let desc = item.venue.description {
                    Text(desc)
                        .font(.system(size: 13))
                        .foregroundColor(Color.Design.textSub)
                        .padding(.top, 4)
                }
                
                if let note = item.note, !note.isEmpty {
                    Text("💡 \(note)")
                        .font(.system(size: 13))
                        .foregroundColor(Color.Design.textSub)
                }
                
                if let transport = item.transportTip, !transport.isEmpty {
                    Text("🚌 \(transport)")
                        .font(.system(size: 13))
                        .foregroundColor(Color.Design.textSub)
                }
                
                HStack {
                    Spacer()
                    Button(action: checkIn) {
                        Image(systemName: item.isCheckedIn ? "checkmark.circle.fill" : "checkmark.circle")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(item.isCheckedIn ? Color.Design.accentGreen : Color.Design.border)
                    }
                    .disabled(item.isCheckedIn)
                }
            }
            .padding()
            .background(Color.Design.surface)
            .cornerRadius(24)
            .padding(.bottom, 16)
        }
    }
    
    private func checkIn() {
        guard !item.isCheckedIn else { return }
        
        // Final duplicate check just before inserting
        if !existingRecords.contains(where: { $0.venueName == item.venue.name }) {
            let record = CheckInRecord(
                venueName: item.venue.name,
                address: item.venue.address,
                latitude: item.venue.latitude ?? 0.0,
                longitude: item.venue.longitude ?? 0.0
            )
            modelContext.insert(record)
        }
        
        withAnimation {
            item.isCheckedIn = true
        }
    }
}
