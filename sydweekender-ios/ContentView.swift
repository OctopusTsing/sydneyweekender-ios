//
//  ContentView.swift
//  sydweekender-ios
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            CheckInMapView()
                .tabItem {
                    Label("Footprint", systemImage: "mappin.and.ellipse")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "bookmark")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
                .tag(3)
        }
        .tint(Color.Design.textMain)
    }
}
