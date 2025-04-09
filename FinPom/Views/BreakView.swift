//
//  BreakView.swift
//  FinPom
//
//  Created by Adrian Alfajri on 09/04/25.
//

import SwiftUI

struct TriviaItem: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
    let quote: String
}

struct BreakView: View {
    enum BreakType {
        case short, long
    }
    let breakType: BreakType
    
    @Environment(\.dismiss) private var dismiss
    @Binding var isShowingBreakView: Bool
    @EnvironmentObject var timerVM: TimerViewModel // Tambahkan ini
    
    @State private var showStartBreakAlert: Bool = false
    @State private var isNextSessionManual: Bool = false
    
    let triviaItems = [
        TriviaItem(imageName: "drinkWater", title: "Water Isn’t Just for Fish, Your Brain Needs It Too! 💧", subtitle: "Your brain is 75% water, if you don’t drink enough your focus drops fast! Even 2% dehydration can make you feel sluggish and forgetful. Stay hydrated, and your mind stays sharp 🦈!", quote: "Your brain runs on water, not WiFi—stay hydrated, stay sharp!"),
        TriviaItem(imageName: "walking", title: "Step Outside & Let Your Ideas Breathe! 🍃", subtitle: "Breathing fresh air can boost your energy by up to 30%! Your brain needs oxygen to work at its best, so don’t stay stuck indoors all day. Just 5 - 10 minutes outside can clear your mind and refresh your thoughts.", quote: "Great ideas don’t live in stuffy rooms step outside and breathe brilliance!"),
        TriviaItem(imageName: "stretching", title: "Sitting Too Long? Time to Stretch! 🤸", subtitle: "Sitting too long slows blood flow and makes your muscles stiff, which leads to fatigue. A quick stretch can instantly refresh your body and lift your mood! Move a little, feel the difference!", quote: "Your body isn’t a statue,  stretch, move,  feel alive🤸🏼!"),
        TriviaItem(imageName: "music", title: "Boost Your Focus Let the Music Work Its Magic! 🎶", subtitle: "Listening to music can boost focus and creativity by 15%! The right rhythm helps your brain stay in the zone and makes work feel effortless. Pick your power playlist and get things done!", quote: "Good music, good mood, great work press play and power up!"),
        TriviaItem(imageName: "meditate", title: "Close Your Eyes, Breathe Reset Your Mind! 🧘", subtitle: "Just 60 seconds of meditation can lower stress and sharpen focus! The more you do it, the better you handle pressure. Never underestimate the power of a quiet moment!", quote: "Silence isn’t empty, it’s where your mind recharges"),
        TriviaItem(imageName: "eyeBreak", title: "Give Your Eyes a Break They Deserve It! 👀", subtitle: "Staring at screens too long strains your eyes and makes you tired. A simple eye and face massage can boost circulation and reduce tension! Happy eyes, better work!", quote: "Happy eyes, happy workday give them a break!"),
        TriviaItem(imageName: "journaling", title: "Brain Overloaded🤯? Spill It on Paper! ✍️", subtitle: "Journaling clears your mind, reduces stress, and boosts creativity! Just 5 minutes of writing can make you feel more in control and at peace. No need for perfect words, just let it flow!", quote: "if your mind feels full, empty it onto paper your brain will thank you!")
    ]
    
    @State private var timeRemaining: Int = 300
    @State private var isRunning = true
    @State private var selectedTrivia: TriviaItem? = nil
    @State private var showTriviaDetail = false
    @State private var hasStoppedTimer = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func addFiveMoreMinutes() {
        timeRemaining += 300
        print("Added 5 minutes. New timeRemaining: \(timeRemaining)")
    }
    
    func stopTimer() {
        isRunning = false
        timeRemaining = breakType == .short ? 300 : 900
        print("Timer stopped. Reset timeRemaining to \(timeRemaining).")
        
        // Cek apakah masih ada sesi focus selanjutnya
        let nextIndex = timerVM.currentSessionIndex + 1
        if nextIndex < timerVM.pomodoroSchedule.count {
            timerVM.currentSessionIndex = nextIndex
            let nextSession = timerVM.pomodoroSchedule[nextIndex]
            timerVM.timeRemaining = nextSession.defaultDuration(multiplier: timerVM.isTestingMode ? 1.0 / 60.0 : 1.0)
            if isNextSessionManual {
                showStartBreakAlert = true
            }
            else {
                timerVM.startTimer()
            }
            isShowingBreakView = false
        } else {
            // Jika tidak ada sesi lagi, kembali ke Home
            timerVM.stopTimer() // Replace with a valid method if available
            isShowingBreakView = false
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text(breakType == .short ? "Short Break" : "Long Break")
                .font(.custom("SF Pro", size: 20))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            
            Text(formattedTime)
                .font(.custom("SF Pro", size: 64))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .onReceive(timer) { _ in
                    guard isRunning else { return }
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else if !hasStoppedTimer {
                        hasStoppedTimer = true
                        isRunning = false
                        stopTimer()
                    }
                }
            
            if let trivia = selectedTrivia {
                VStack(spacing: 8) {
                    Text(trivia.quote)
                        .foregroundColor(.white)
                        .font(.custom("SF Pro", size: 20))
                        .bold()
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    Button(action: {
                        showTriviaDetail = true
                        print("Trivia selected: \(trivia.title)")
                    }) {
                        Text("See Why")
                            .font(.custom("SF Pro", size: 20))
                            .foregroundColor(.white)
                            .bold()
                    }
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                }
            }
            
            HStack(spacing: 16) {
                Button(action: addFiveMoreMinutes) {
                    Text("+5 minutes")
                        .foregroundColor(Color.black)
                        .font(.custom("SF Pro", size: 20))
                        .fontWeight(.bold)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#FFD166"))
                        .cornerRadius(16)
                }
                
                Button(action: {
                    stopTimer()
                }) {
                    Text("Stop")
                        .foregroundColor(.white)
                        .font(.custom("SF Pro", size: 20))
                        .fontWeight(.bold)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "#FF6B6B"))
                        .cornerRadius(16)
                }
            }
            .padding(.horizontal, 30)
            
            GifImage("jeff")
                .frame(width: 100, height: 250)
        }
        .padding(.horizontal, 30)
        .background(Color.background)
        .onAppear {
            if selectedTrivia == nil {
                selectedTrivia = triviaItems.randomElement()
                print("Trivia set: \(selectedTrivia?.title ?? "None")")
            }
            showTriviaDetail = true
            if timerVM.isPresentingStartBreakModal {
                showStartBreakAlert = true
                timerVM.isPresentingStartBreakModal = false
            }
        }
        .onDisappear {
            isRunning = false
        }
        .sheet(isPresented: $showTriviaDetail) {
            if let selectedTrivia {
                TriviaDetailView(item: selectedTrivia)
                    .presentationDetents([.medium])
            }
        }
        .alert("Great job completing your focus session! 🎉", isPresented: $showStartBreakAlert) {
            Button("Start Break") {
                timerVM.startTimer()
                isShowingBreakView = false
            }
        } message: {
            Text("Tap to start your break session.")
        }
    }
}

struct TriviaDetailView: View {
    let item: TriviaItem
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Image Banner
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(15)
                    .frame(maxWidth: .infinity)
                
                // Title
                Text(item.title)
                    .font(.custom("SF Pro", size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Subtitle
                Text(item.subtitle)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }){
                        Text("Done").foregroundColor(.blue)
                    }
                }
            }
        }
    }
}


#Preview {
    BreakView(breakType: .short, isShowingBreakView: .constant(true))
}

