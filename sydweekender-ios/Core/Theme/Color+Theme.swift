//
//  Color+Theme.swift
//  sydweekender-ios
//

import SwiftUI

/// A utility extension to initialize SwiftUI Color using hex strings.
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

/// Core design system colors extracted from the Android app.
extension Color {
    struct Design {
        static let background = Color(hex: "#F5F3EF")
        static let surface = Color(hex: "#FFFFFF")
        static let primary = Color(hex: "#1A1A1A")
        
        static let accentGreen = Color(hex: "#5B7B61")
        static let accentOrange = Color(hex: "#E88B6A")
        
        static let textMain = Color(hex: "#1A1A1A")
        static let textSub = Color(hex: "#7A7875")
        
        static let cardBackground = Color(hex: "#FCFAF7")
        static let border = Color(hex: "#E0DDD8")
        
        // Status Colors
        static let statusBlue = Color(hex: "#E8F0F8")
        static let statusBlueText = Color(hex: "#4A6B8C")
        static let statusOrange = Color(hex: "#FFF7ED")
        static let statusOrangeText = Color(hex: "#9A3412")
        static let statusGreen = Color(hex: "#ECFDF5")
        static let statusGreenText = Color(hex: "#065F46")
    }
}
