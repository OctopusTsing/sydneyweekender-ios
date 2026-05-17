//
//  SettingsView.swift
//  sydweekender-ios
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("ai_api_key") private var apiKey: String = ""
    @AppStorage("ai_api_url") private var apiUrl: String = "https://generativelanguage.googleapis.com/v1beta/openai/"
    @AppStorage("ai_model") private var model: String = "gemini-2.5-flash"
    
    @State private var inputApiKey: String = ""
    @State private var inputApiUrl: String = ""
    @State private var inputModel: String = ""
    
    @State private var showSaveAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.Design.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Info Card
                        VStack(alignment: .leading, spacing: 8) {
                            Text("ℹ️ AI Generation")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color.Design.statusBlueText)
                            Text("Enter your own API keys for AI generation. Leave blank for default or offline modes.")
                                .font(.system(size: 14))
                                .foregroundColor(Color.Design.statusBlueText.opacity(0.9))
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.Design.statusBlue)
                        .cornerRadius(24)
                        
                        Text("AI Configuration")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                            .foregroundColor(Color.Design.textMain)
                            .padding(.top, 12)
                        
                        // Inputs Card
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AI API KEY")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color.Design.textSub)
                                SecureField("sk-...", text: $inputApiKey)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.Design.border, lineWidth: 1))
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("BASE URL")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color.Design.textSub)
                                TextField("https://...", text: $inputApiUrl)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.Design.border, lineWidth: 1))
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("MODEL NAME")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color.Design.textSub)
                                TextField("gpt-4o", text: $inputModel)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.Design.border, lineWidth: 1))
                            }
                        }
                        .padding()
                        .background(Color.Design.cardBackground)
                        .cornerRadius(24)
                        
                        Button(action: saveSettings) {
                            Text("SAVE CHANGES")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.Design.primary)
                                .cornerRadius(28)
                        }
                        .padding(.top, 16)
                        .alert("Settings Saved", isPresented: $showSaveAlert) {
                            Button("OK", role: .cancel) { }
                        }
                        
                        Button(action: clearSettings) {
                            Text("RESET CREDENTIALS")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.Design.textMain)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.clear)
                                .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.Design.border, lineWidth: 1))
                        }
                        .padding(.top, 4)
                        
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                inputApiKey = apiKey
                inputApiUrl = apiUrl
                inputModel = model
            }
        }
    }
    
    private func saveSettings() {
        apiKey = inputApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let trimmedUrl = inputApiUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedUrl.isEmpty { apiUrl = trimmedUrl }
        
        let trimmedModel = inputModel.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedModel.isEmpty { model = trimmedModel }
        
        showSaveAlert = true
    }
    
    private func clearSettings() {
        inputApiKey = ""
        apiKey = ""
    }
}
