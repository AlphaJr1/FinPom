//
//  TimerViewModel.swift
//  FinPom
//
//  Created by Adrian Alfajri on 03/04/25.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications
import UIKit
import AudioToolbox

class TimerViewModel: ObservableObject {
    @Published var selectedTime: TimeInterval = 1500 // Default 25 menit
    @Published var timeRemaining: TimeInterval = 1500
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var startedAt: Date?
    @Published var pomodoroSchedule: [PomodoroCycle.SessionType] = []
    @Published var currentSessionIndex: Int = 0
    @Published var currentSession: PomodoroCycle.SessionType = .focus
    var currentSessionDuration: TimeInterval = 25 * 60
    @Published var totalRemainingTime: TimeInterval = 0
    var isTestingMode = false
    @Published var shouldReturnToRunningView = false
    @Published var shouldResumeAfterPause: Bool = false
    
    private var timer: AnyCancellable?
    private var hasScheduledPreBreakNotification = false
    
    private func switchSession() {
        switch currentSession {
        case .focus:
            currentSession = .shortBreak
            currentSessionDuration = 5 * 60
        case .shortBreak:
            currentSession = .focus
            currentSessionDuration = 25 * 60
        case .longBreak:
            currentSession = .focus
            currentSessionDuration = 25 * 60
        }
        timeRemaining = currentSessionDuration
        startTimer()
    }
    
    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        isPaused = false
        startedAt = Date()
        hasScheduledPreBreakNotification = false
        
        guard currentSessionIndex < pomodoroSchedule.count else {
            stopTimer()
            return
        }

        currentSession = pomodoroSchedule[currentSessionIndex]
        if currentSession == .longBreak {
            NotificationManager.sendLongBreakNotification()
        }
        switch currentSession {
        case .focus:
            timeRemaining = isTestingMode ? 70 : 25 * 60
        case .shortBreak:
            timeRemaining = isTestingMode ? 10 : 5 * 60
        case .longBreak:
            timeRemaining = isTestingMode ? 20 : 15 * 60
        }

        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func pauseTimer() {
        guard isRunning else { return }
        isPaused = true
        isRunning = false
        timer?.cancel()
    }
    
    func resumeTimer() {
        guard isPaused else { return }
        isPaused = false
        isRunning = true
        shouldReturnToRunningView = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func stopTimer() {
        isRunning = false
        isPaused = false
        timer?.cancel()
        timer = nil
        timeRemaining = selectedTime
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            timer?.cancel()
            if currentSession == .focus {
                print("🎉 Fokus selesai, masuk ke break session.")
                NotificationManager.sendBreakNotification()

                // Suara sistem
                AudioServicesPlaySystemSound(1005)

                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }

            if currentSession == .longBreak {
                print("🛌 Memasuki long break.")
                NotificationManager.sendLongBreakNotification()
                AudioServicesPlaySystemSound(1005)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            
            totalRemainingTime -= selectedTime
            
            currentSessionIndex += 1
            
            guard currentSessionIndex < pomodoroSchedule.count else {
                stopTimer()
                return
            }
            startTimer()
            return
        }
        
        if timeRemaining == 60 && currentSession == .focus && !hasScheduledPreBreakNotification {
            hasScheduledPreBreakNotification = true
            print("🔔 Notifikasi ringan 1 menit sebelum break berhasil dipicu.")

            // Local notification
            let content = UNMutableNotificationContent()
            content.title = "Almost break time!"
            content.body = "Break session will start in 1 minute."
            content.sound = nil

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)

            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        
        timeRemaining -= 1
    }
    
    func resetReturnFlag() {
        shouldReturnToRunningView = false
    }
    
    // MARK: - Utility
    func shouldEnterBreak() -> Bool {
        guard let startedAt = startedAt else { return false }
        let duration = Date().timeIntervalSince(startedAt)
        return duration >= 300 // 5 menit
    }
    
    func setupPomodoroSchedule(totalDuration: TimeInterval) {
        let cycle = PomodoroCycle(totalDuration: totalDuration)
        pomodoroSchedule = cycle.generateSchedule()
        currentSessionIndex = 0
        totalRemainingTime = totalDuration
    }
}


struct PomodoroCycle {
    var totalDuration: TimeInterval // total durasi user, misalnya 8 jam
    var focusDuration: TimeInterval = 25 * 60 // 25 menit
    var shortBreak: TimeInterval = 5 * 60      // 5 menit
    var longBreak: TimeInterval = 15 * 60      // 15 menit
    var sessionsBeforeLongBreak: Int = 4       // 4 fokus → 1 long break

    var numberOfFocusSessions: Int {
        let cycleLength = focusDuration + shortBreak
        let fullCycle = TimeInterval(sessionsBeforeLongBreak) * cycleLength + longBreak
        let totalCycles = totalDuration / fullCycle
        let remainingTime = totalDuration - floor(totalCycles) * fullCycle
        let additionalFocusSessions = Int(remainingTime / (focusDuration + shortBreak))

        let result = Int(floor(totalCycles)) * sessionsBeforeLongBreak + additionalFocusSessions
        return max(result, 1)
    }

    func generateSchedule() -> [SessionType] {
        var schedule: [SessionType] = []

        guard numberOfFocusSessions > 0 else {
            return schedule
        }

        for i in 1...numberOfFocusSessions {
            schedule.append(.focus)
            if i % sessionsBeforeLongBreak == 0 {
                schedule.append(.longBreak)
            } else {
                schedule.append(.shortBreak)
            }
        }

        return schedule
    }

    enum SessionType {
        case focus
        case shortBreak
        case longBreak
    }
}
