//
//  CheckInMapView.swift
//  sydweekender-ios
//

import SwiftUI
import MapKit
import SwiftData

struct CheckInMapView: View {
    @Query(sort: \CheckInRecord.checkInTime, order: .reverse) private var records: [CheckInRecord]
    @Environment(\.modelContext) private var modelContext
    
    @State private var position: MapCameraPosition = .automatic
    @State private var isListExpanded = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position) {
                ForEach(records, id: \.id) { record in
                    if record.latitude != 0.0 {
                        Annotation(record.venueName, coordinate: CLLocationCoordinate2D(latitude: record.latitude, longitude: record.longitude)) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(Color.Design.accentOrange)
                                .font(.title)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Text("My Footprint")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(Color.Design.textMain)
                    
                    Spacer()
                    
                    Text("\(records.count) Visited")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.Design.accentGreen)
                }
                .padding()
                .background(Color.Design.surface)
                .cornerRadius(28)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                .padding()
                
                // Toggle List
                if !records.isEmpty {
                    VStack(spacing: 0) {
                        HStack {
                            Text(isListExpanded ? "\(records.count) Locations" : "Tap to view locations")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.Design.textMain)
                            Spacer()
                            Image(systemName: isListExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(Color.Design.textSub)
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(isListExpanded ? 0 : 20)
                        .clipShape(
                            .rect(
                                topLeadingRadius: 20,
                                bottomLeadingRadius: isListExpanded ? 0 : 20,
                                bottomTrailingRadius: isListExpanded ? 0 : 20,
                                topTrailingRadius: 20
                            )
                        )
                        .onTapGesture {
                            withAnimation(.spring) {
                                isListExpanded.toggle()
                            }
                        }
                        
                        if isListExpanded {
                            ScrollView {
                                LazyVStack {
                                    ForEach(records) { record in
                                        HStack {
                                            Image(systemName: "mappin.and.ellipse")
                                                .foregroundColor(.white)
                                                .padding(8)
                                                .background(Color.Design.accentOrange)
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading) {
                                                Text(record.venueName)
                                                    .font(.system(size: 15, weight: .bold))
                                                    .foregroundColor(Color.Design.textMain)
                                                Text(record.address ?? "Location")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color.Design.textSub)
                                            }
                                            Spacer()
                                            
                                            Button {
                                                modelContext.delete(record)
                                            } label: {
                                                Image(systemName: "trash")
                                                    .foregroundColor(Color.Design.accentOrange)
                                            }
                                        }
                                        .padding()
                                        .background(Color.Design.surface)
                                        .cornerRadius(16)
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            .frame(maxHeight: 300)
                            .background(Color.white.opacity(0.9))
                            .clipShape(
                                .rect(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 20,
                                    bottomTrailingRadius: 20,
                                    topTrailingRadius: 0
                                )
                            )
                        }
                    }
                    .padding(.horizontal)
                } else {
                    VStack {
                        Text("📍")
                            .font(.system(size: 48))
                        Text("No check-ins yet")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.Design.textMain)
                        Text("Tap a pin on the map to check in!")
                            .font(.system(size: 13))
                            .foregroundColor(Color.Design.textSub)
                    }
                    .padding(32)
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(20)
                    .padding()
                }
            }
        }
        .onAppear {
            if let first = records.first(where: { $0.latitude != 0.0 }) {
                position = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: first.latitude, longitude: first.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
            } else {
                position = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)))
            }
        }
    }
}
