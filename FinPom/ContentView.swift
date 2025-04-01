//
//  ContentView.swift
//  FinPom
//
//  Created by Adrian Alfajri on 21/03/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @State private var selectedMinutes: Int
    @State private var timeRemaining: Int
    @State private var timerRunning = false
    @State private var isBreakSession = false
    @State private var breakTimeRemaining: Int = 0
    @State private var currentActivity: String = ""
    @State private var currentQuote: String = ""
    @State private var focusElapsedTime: Int = 0
    @State private var isPressing = false
    @State private var hasTriggeredReset = false
    
    @State private var timer: Timer? = nil
    @State private var longPressProgress: CGFloat = 0
    @State private var longPressTimer: Timer? = nil
    
    let testingMode = true
    
    init() {
        let initialMinutes = 25
        _selectedMinutes = State(initialValue: initialMinutes)
        _timeRemaining = State(initialValue: initialMinutes * 60)
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                
                if isBreakSession {
                    Text("Break Session")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(currentActivity)
                        .font(.title2)
                        .padding(.bottom, 10)

                    Text("💡 \(currentQuote)")
                        .italic()
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)

                    Text("\(timeString(from: breakTimeRemaining))")
                        .font(.system(size: 60, weight: .semibold, design: .monospaced))
                        .padding()
                        .animation(.easeInOut, value: breakTimeRemaining)
                    
                    HStack(spacing: 20) {
                        Button(action: addBreakTime) {
                            Label("Add +5 min", systemImage: "plus.circle")
                                .frame(minWidth: 120)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        Button(action: stopBreakSession) {
                            Label("Stop", systemImage: "stop.circle")
                                .frame(minWidth: 120)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                } else {
                    Text("Focus Session")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(timeString(from: timeRemaining))")
                        .font(.system(size: 60, weight: .semibold, design: .monospaced))
                        .padding()
                        .animation(.easeInOut, value: timeRemaining)
                    
                    Picker("Duration", selection: $selectedMinutes) {
                        ForEach(Array(stride(from: 5, through: 60, by: 5)), id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 100)
                    .disabled(timerRunning)
                    .onChange(of: selectedMinutes) { oldValue, newValue in
                        timeRemaining = newValue * 60
                    }
                    
                    ZStack {
                        VStack {
                            if longPressProgress > 0 {
                                ProgressView(value: longPressProgress)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .red))
                                    .frame(width: 150)
                                    .padding(.bottom, 8)
                                    .animation(.linear, value: longPressProgress)
                            }

                            Label(timerRunning ? "Pause" : "Start", systemImage: timerRunning ? "pause.circle" : "play.circle")
                                .frame(minWidth: 150)
                                .padding()
                                .background(timerRunning ? Color.orange : Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 8)
                                .onLongPressGesture(minimumDuration: 1) {
                                    print(">>> Long Press <<<\n")}
                                .onTapGesture {
                                    if !timerRunning {
                                        startTimer()
                                    } else {
                                        pauseTimer()
                                }
                                
                            }
                        }
                    }
                    
//                    .gesture(
//                        DragGesture(minimumDistance: 0)
//                            .onChanged { _ in
//                                if !isPressing {
//                                    isPressing = true
//                                    startLongPressProgress()
//                                }
//                            }
//                            .onEnded { _ in
//                                isPressing = false
//                                stopLongPressProgress()
//                            }
//                    )
                }
            }
            .padding()
        }
    }
    
    func startTimer() {
        timerRunning = true
        let interval = testingMode ? 0.0333 : 1.0
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
                focusElapsedTime += 1
            } else {
                timer?.invalidate()
                timerRunning = false
                focusElapsedTime = selectedMinutes * 60
                startBreakSession()
            }
        }
    }
    
    func pauseTimer() {
        timerRunning = false
        timer?.invalidate()
    }
    
    func resetTimer() {
        pauseTimer()

        if focusElapsedTime >= 300 {
            // Jika telah fokus minimal 5 menit, langsung break
            focusElapsedTime = selectedMinutes * 60
            startBreakSession()
        } else {
            // Jika belum 5 menit, reset ke awal tanpa break
            timeRemaining = selectedMinutes * 60
            focusElapsedTime = 0
            isBreakSession = false
        }
    }
    
    func startBreakSession() {
        guard selectedMinutes >= 5 else { return }
        isBreakSession = true
        
        // Pomodoro rule breaktime
        let breakMinutes: Int
        if selectedMinutes >= 25 {
            breakMinutes = 5
        } else {
            breakMinutes = 3
        }
        
        breakTimeRemaining = breakMinutes * 60
        generateBreakRecommendations()
        startBreakTimer()
    }
    
    func startBreakTimer() {
        let interval = testingMode ? 0.0333 : 1.0
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            if breakTimeRemaining > 0 {
                breakTimeRemaining -= 1
            } else {
                timer?.invalidate()
                isBreakSession = false
                timeRemaining = selectedMinutes * 60
            }
        }
    }
    
    func addBreakTime() {
        breakTimeRemaining += 5 * 60 // +5 menit
    }
    
    func stopBreakSession() {
        timer?.invalidate()
        isBreakSession = false
        timeRemaining = selectedMinutes * 60
        focusElapsedTime = 0
    }
    
    func generateBreakRecommendations() {
        let activities = [
            "💪 Do some light stretching",
            "🚶‍♂️ Take a short walk",
            "💧 Drink water",
            "😌 Practice deep breathing",
            "👀 Rest your eyes for 20 seconds"
        ]
        
        let quotes = [
            "Rest is productive.",
            "Your focus deserves this reward.",
            "You’re one break closer to your goal.",
            "Small breaks bring big results.",
            "Recharge and conquer!"
        ]
        
        currentActivity = activities.randomElement() ?? ""
        currentQuote = quotes.randomElement() ?? ""
    }
    
    
    func startLongPressProgress() {
        longPressProgress = 0
        hasTriggeredReset = false
        longPressTimer?.invalidate()
        
        triggerHapticFeedback(style: .light)
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            if longPressProgress < 1.0 {
                longPressProgress += 0.0166 // sekitar 3s
            } else {
                if !hasTriggeredReset {
                    hasTriggeredReset = true
                    longPressTimer?.invalidate()
                    pauseTimer()
                    resetTimer()
                    triggerHapticFeedback(style: .heavy)
                }
            }
        }
    }

    func stopLongPressProgress() {
        longPressTimer?.invalidate()
        if longPressProgress < 1.0 {
            longPressProgress = 0
            hasTriggeredReset = false
        }
    }
    
    func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ContentView()
}
