//
//  HomeView.swift
//  sydweekender-ios
//

import SwiftUI
import Combine

struct HomeView: View {
    @State private var selectedDate = Date()
    @State private var groupSizeStr = "1"
    @FocusState private var isGroupSizeFocused: Bool
    
    @State private var isHikingSelected = false
    @State private var isCafeSelected = false
    @State private var isArtSelected = false
    @State private var isBeachSelected = false
    @State private var isFoodSelected = false
    
    @State private var isNavigating = false
    @State private var generatedInterests: [String] = []
    
    @State private var showError = false
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    
    // Hero Image States
    @State private var heroImages: [String] = []
    @State private var currentImageIndex = 0
    @State private var currentImageName: String = "Sydney Weekender"
    
    private static let heroRotationInterval: TimeInterval = 6
    private let heroFadeDuration: TimeInterval = 1.2
    
    let timer = Timer.publish(every: HomeView.heroRotationInterval, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Sydney Weekender")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundColor(Color.Design.textMain)
                        .padding(.horizontal)
                    
                    // Hero Section
                    ZStack {
                        // Base background to ensure stable frame
                        Color.Design.background
                        
                        if !heroImages.isEmpty {
                            GeometryReader { proxy in
                                ZStack {
                                    ForEach(heroImages.indices, id: \.self) { index in
                                        if let uiImage = loadHeroImage(named: heroImages[index]) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: proxy.size.width, height: proxy.size.height)
                                                .clipped()
                                                .opacity(index == currentImageIndex ? 1 : 0)
                                        }
                                    }
                                }
                                .animation(.easeInOut(duration: heroFadeDuration), value: currentImageIndex)
                            }
                        } else {
                            Image(systemName: "globe.asia.australia.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.white.opacity(0.2))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .overlay(alignment: .bottomLeading) {
                        Text(currentImageName)
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundColor(Color.Design.textMain)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(16)
                            .padding([.leading, .bottom], 20)
                            .animation(.easeInOut, value: currentImageName)
                    }
                    .cornerRadius(32)
                    .padding(.horizontal)
                    .onReceive(timer) { _ in
                        cycleHeroImage()
                    }
                    .onAppear {
                        loadHeroFileList()
                    }
                    
                    Text("Customize your trip")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundColor(Color.Design.textMain)
                        .padding(.horizontal)
                        .padding(.top, 12)
                    
                    // Input Card
                    VStack(alignment: .leading, spacing: 16) {
                        DatePicker("Travel Date", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                            .padding()
                            .background(Color.Design.surface)
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.Design.border, lineWidth: 1))
                        
                        HStack {
                            Text("Group Size")
                            TextField("1-20", text: $groupSizeStr)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .focused($isGroupSizeFocused)
                                .onChange(of: groupSizeStr) {
                                    let filtered = groupSizeStr.filter { "0123456789".contains($0) }
                                    if filtered.count > 2 {
                                        groupSizeStr = String(filtered.prefix(2))
                                    } else if filtered != groupSizeStr {
                                        groupSizeStr = filtered
                                    }
                                }
                        }
                        .padding()
                        .background(Color.Design.surface)
                        .cornerRadius(16)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.Design.border, lineWidth: 1))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isGroupSizeFocused = true
                        }
                        
                        Text("Interests")
                            .font(.system(size: 14, weight: .bold, design: .serif))
                            .foregroundColor(Color.Design.textMain)
                            .padding(.top, 12)
                        
                        VStack(spacing: 0) {
                            InterestToggleRow(title: "Hiking", isSelected: $isHikingSelected)
                            Divider().background(Color.Design.border)
                            InterestToggleRow(title: "Cafe Hopping", isSelected: $isCafeSelected)
                            Divider().background(Color.Design.border)
                            InterestToggleRow(title: "Art Exhibitions", isSelected: $isArtSelected)
                            Divider().background(Color.Design.border)
                            InterestToggleRow(title: "Beaches", isSelected: $isBeachSelected)
                            Divider().background(Color.Design.border)
                            InterestToggleRow(title: "Budget Eats", isSelected: $isFoodSelected)
                        }
                        
                        Button(action: generateItinerary) {
                            Text("GENERATE ITINERARY")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.Design.primary)
                                .cornerRadius(28)
                        }
                        .padding(.top, 16)
                        .alert(errorTitle, isPresented: $showError) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text(errorMessage)
                        }
                        
                    }
                    .padding()
                    .background(Color.Design.cardBackground)
                    .cornerRadius(24)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.Design.background.ignoresSafeArea())
            .navigationDestination(isPresented: $isNavigating) {
                ItineraryView(
                    date: selectedDate,
                    groupSize: Int(groupSizeStr) ?? 1,
                    interests: generatedInterests
                )
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isGroupSizeFocused = false
                    }
                }
            }
        }
    }
    
    // MARK: - Hero Image Logic
    
    private var currentHeroImageFileName: String? {
        guard heroImages.indices.contains(currentImageIndex) else { return nil }
        return heroImages[currentImageIndex]
    }
    
    private func loadHeroFileList() {
        let extensions = ["jpg", "jpeg", "png", "JPG", "JPEG", "PNG"]
        var files: [String] = []
        
        for ext in extensions {
            if let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: "hero_images") {
                let filteredUrls = urls.map { $0.lastPathComponent }.filter { $0.lowercased().hasPrefix("hero_") }
                files.append(contentsOf: filteredUrls)
            }
            
            if let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) {
                let filteredUrls = urls.map { $0.lastPathComponent }.filter { $0.lowercased().hasPrefix("hero_") }
                files.append(contentsOf: filteredUrls)
            }
        }
        
        heroImages = Array(Set(files)).sorted()
        
        if !heroImages.isEmpty {
            currentImageIndex = Int.random(in: 0..<heroImages.count)
            updateHeroName()
        }
    }
    
    private func cycleHeroImage() {
        guard heroImages.count > 1 else { return }
        var newIndex = Int.random(in: 0..<heroImages.count)
        while newIndex == currentImageIndex {
            newIndex = Int.random(in: 0..<heroImages.count)
        }
        
        withAnimation(.easeInOut(duration: 0.45)) {
            currentImageIndex = newIndex
            updateHeroName()
        }
    }
    
    private func updateHeroName() {
        guard heroImages.indices.contains(currentImageIndex) else { return }
        
        let fileName = heroImages[currentImageIndex]
        var displayName = fileName
        // Remove prefix and extension
        if displayName.lowercased().hasPrefix("hero_") {
            displayName = String(displayName.dropFirst(5))
        }
        if let dotIndex = displayName.lastIndex(of: ".") {
            displayName = String(displayName[..<dotIndex])
        }
        displayName = displayName.replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: "-", with: " ")
        currentImageName = displayName.capitalized
    }
    
    private func loadHeroImage(named fileName: String) -> UIImage? {
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil, subdirectory: "hero_images"),
           let image = UIImage(contentsOfFile: url.path) {
            return image
        }
        
        if let url = Bundle.main.url(forResource: fileName, withExtension: nil),
           let image = UIImage(contentsOfFile: url.path) {
            return image
        }
        
        return UIImage(named: fileName)
    }
    
    // MARK: - Generation Logic
    
    private func generateItinerary() {
        var selected: [String] = []
        if isHikingSelected { selected.append("hiking") }
        if isCafeSelected { selected.append("cafe_hopping") }
        if isArtSelected { selected.append("art_exhibitions") }
        if isBeachSelected { selected.append("beaches") }
        if isFoodSelected { selected.append("budget_eats") }
        
        let size = Int(groupSizeStr) ?? 0
        
        if size < 1 || size > 20 {
            errorTitle = "Invalid Group Size"
            errorMessage = "Please enter a valid number of people between 1 and 20."
            showError = true
            return
        }
        
        if selected.isEmpty {
            errorTitle = "Missing Interests"
            errorMessage = "Please select at least one interest to generate your itinerary."
            showError = true
            return
        }
        
        generatedInterests = selected
        isNavigating = true
    }
}

struct InterestToggleRow: View {
    let title: String
    @Binding var isSelected: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: isSelected ? .bold : .regular, design: .serif))
                .foregroundColor(isSelected ? Color.Design.textMain : Color.Design.textSub)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(Color.Design.primary)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding(.vertical, 18)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                isSelected.toggle()
            }
        }
    }
}
