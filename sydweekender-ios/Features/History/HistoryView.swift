//
//  HistoryView.swift
//  sydweekender-ios
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \SavedItinerary.createdAt, order: .reverse) private var itineraries: [SavedItinerary]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.Design.background.ignoresSafeArea()
                
                if itineraries.isEmpty {
                    VStack {
                        Text("🧳")
                            .font(.system(size: 64))
                        Text("No adventures yet")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(Color.Design.textMain)
                            .padding(.top, 16)
                        Text("Plan your first trip in the main screen.")
                            .font(.system(size: 14))
                            .foregroundColor(Color.Design.textSub)
                            .padding(.top, 8)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(itineraries) { itinerary in
                                HistoryRow(itinerary: itinerary) {
                                    modelContext.delete(itinerary)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct HistoryRow: View {
    let itinerary: SavedItinerary
    let onDelete: () -> Void
    
    var itemsCount: Int {
        if let data = itinerary.itemsJSON.data(using: .utf8),
           let items = try? JSONDecoder().decode([ItineraryItem].self, from: data) {
            return items.count
        }
        return 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(itinerary.title)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(Color.Design.textMain)
                Spacer()
                Button(action: onDelete) {
                    Text("🗑️")
                        .font(.system(size: 14))
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                }
            }
            
            Text(itinerary.date)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color.Design.accentGreen)
            
            Text(itinerary.interests)
                .font(.system(size: 13))
                .foregroundColor(Color.Design.textSub)
            
            Text(itinerary.weatherSummary)
                .font(.system(size: 11))
                .foregroundColor(Color.Design.textSub)
            
            HStack {
                Text("\(itemsCount) Stops")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color.Design.textMain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#F0F4F0"))
                    .cornerRadius(12)
                
                Spacer()
                
                Text(itinerary.createdAt.formatted(.relative(presentation: .named)))
                    .font(.system(size: 11))
                    .foregroundColor(Color.Design.textSub)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.Design.surface)
        .cornerRadius(24)
    }
}
