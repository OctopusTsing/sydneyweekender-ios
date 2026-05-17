//
//  AppConfig.swift
//  sydweekender-ios
//

import SwiftUI

class AppConfig {
    @AppStorage("ai_api_key") static var apiKey: String = ""
    @AppStorage("ai_api_url") static var apiUrl: String = "https://generativelanguage.googleapis.com/v1beta/openai/"
    @AppStorage("ai_model") static var model: String = "gemini-2.5-flash"
}
