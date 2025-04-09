//
//  SettingView.swift
//  setting finpoms
//
//  Created by grace maria yosephine agustin gultom on 07/04/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("soundEffectsEnabled") private var soundEffectsEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General Settings")) {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                        Text("Switch to Light Mode for clarity or Dark Mode for comfort. Choose your perfect view!")
                            .font(.caption)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)                    }
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Notifications", systemImage: "bell.fill")
                        Text("Stay on track with reminders for focus, breaks, and tasks to keep productivity flowing.")
                            .font(.caption)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Section(header: Text("Sounds")) {
                    Toggle(isOn: $soundEffectsEnabled) {
                        Label("Sound Effects", systemImage: "speaker.wave.2.fill")
                        Text("Boost your focus with calming background sounds")
                            .font(.caption)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Toggle(isOn: $vibrationEnabled) {
                        Label("Vibration", systemImage: "iphone.radiowaves.left.and.right")
                        Text("Get gentle vibration alerts to signal session changes between focus and break times.")
                            .font(.caption)
                            .fontWeight(.light)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Section(header: Text("More")) {
                    NavigationLink(destination: RateUsView()) {
                        VStack(alignment: .leading) {
                            Label("Rate Us", systemImage: "star.fill")
                            Text("Give your feedback with star rating.")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    NavigationLink(destination: AboutUsView()) {
                        Label("About Us", systemImage: "info.circle.fill")
                    }
                }
            }
            
            .navigationTitle("Settings")
            
            .preferredColorScheme(isDarkMode ? .dark : .light)
            
            
                }
            }
        }

        

    
    struct AboutUsView: View {
        var body: some View {
            VStack(spacing: 20) {
                Text("About Us")
                    .font(.largeTitle)
                    .bold()
                Text("This app is developed to help you manage your time efficiently.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .padding()
            .navigationTitle("About Us")
        }
    }
    
    struct RateUsView: View {
        @AppStorage("userRating") private var userRating: Int = 0
        @Environment(\.presentationMode) var presentationMode

        var body: some View {
            VStack {
                Spacer()

                VStack(spacing: 16) {
                    Text("Enjoy a Better Focus Experience?")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .bold()
                    
                    Text("Help us improve by leaving a review!")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= userRating ? "star.fill" : "star")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.yellow)
                                .onTapGesture {
                                    userRating = index
                                    if index >= 4 {
                                        requestReview()
                                    }
                                }
                                .scaleEffect(index == userRating ? 1.2 : 1.0)
                                .animation(.spring(), value: userRating)
                        }
                    }

                    if userRating > 0 {
                        Text("Thanks for rating us \(userRating) star\(userRating > 1 ? "s" : "")!")
                            .font(.subheadline)
                            .foregroundColor(.green)
                            .padding(.top, 8)
                    }

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()  // Balik ke Settings
                    }) {
                        Text("Submit")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.top, 5.0)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.all)
            .navigationTitle("Rate Us")
        }

        func requestReview() {
            guard let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID?action=write-review") else { return }
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
func triggerVibration() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    #Preview {
        SettingsView()
    }

