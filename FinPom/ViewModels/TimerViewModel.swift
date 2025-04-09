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
    @Published var selectedTime: TimeInterval = 1500 // Default 25m
    @Published var timeRemaining: TimeInterval = 1500
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var pomodoroSchedule: [PomodoroCycle.SessionType] = []
    @Published var currentSessionIndex: Int = 0
    @Published var currentSession: PomodoroCycle.SessionType = .focus
    var currentSessionDuration: TimeInterval = 25 * 60
    @Published var totalRemainingTime: TimeInterval = 0
    var isTestingMode = false
    @Published var shouldReturnToRunningView = false
    @Published var shouldResumeAfterPause: Bool = false
    @Published var isBreakTimeTriggered = false
    @Published var isPresentingStartBreakModal: Bool = false
    private var startedAt: Date?
    
    private var timer: AnyCancellable?
    private var hasScheduledPreBreakNotification = false
    private var hasScheduledBreakNotification = false
    
    private var testingMultiplier: Double {
        isTestingMode ? 1.0 / 60.0 : 1.0
    }
    
    deinit {
        print("🧹 TimerViewModel deallocated")
    }
    
    private func sendHardBreakNotification() {
        print("🔔 HARD NOTIFICATION: Focus session ended. Sending break notification.")
        NotificationManager.sendBreakNotification(isTestingMode: isTestingMode)
        AudioLoopManager.shared.startLoopingSound()
        print("📢 Break notification sent with sound and haptic.")

        AudioServicesPlaySystemSound(1016)

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    private func switchSession() {
        switch currentSession {
        case .focus:
            currentSession = .shortBreak
            currentSessionDuration = 5 * 60 * testingMultiplier
        case .shortBreak:
            currentSession = .focus
            currentSessionDuration = 25 * 60 * testingMultiplier
        case .longBreak:
            currentSession = .focus
            currentSessionDuration = 25 * 60 * testingMultiplier
        }
        timeRemaining = currentSessionDuration
        startTimer()
    }
    
    func startTimer() {
        guard !isRunning else { return }
        hasScheduledBreakNotification = false
        hasScheduledPreBreakNotification = false
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        isRunning = true
        startedAt = Date()
        isPaused = false

        guard currentSessionIndex < pomodoroSchedule.count else {
            stopTimer()
            return
        }

        currentSession = pomodoroSchedule[currentSessionIndex]

        // Hanya set waktu jika belum pernah dimulai (bukan dari resume)
        if timeRemaining <= 0 {
            timeRemaining = currentSession.defaultDuration(multiplier: testingMultiplier)
            if isTestingMode && currentSession == .focus {
                print("🧪 Testing mode aktif, durasi focus session: \(currentSessionDuration) detik.")
            }
        }

        if currentSession == .longBreak {
            NotificationManager.sendLongBreakNotification(isTestingMode: isTestingMode)
            print("📢 Jadwal notifikasi long break dikirim.")
        }

        let interval = 1.0 * testingMultiplier
        timer = Timer.publish(every: interval, on: .main, in: .common)
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
        print("⏸️ Timer dijeda.")
    }
    
    func resumeTimer() {
        guard isPaused else { return }
        isPaused = false
        isRunning = true
        shouldReturnToRunningView = true
        print("▶️ Timer dilanjutkan.")

        let interval = 1.0 * testingMultiplier
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }
    
    func stopTimer() {
        isRunning = false
        isPaused = false
        timer?.cancel()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        timer = nil
        print("⏹️ Timer dihentikan.")
        
        let nextIndex = currentSessionIndex + 1
        if nextIndex < pomodoroSchedule.count {
            currentSessionIndex = nextIndex
            let nextSession = pomodoroSchedule[nextIndex]
            timeRemaining = nextSession.defaultDuration(multiplier: isTestingMode ? 1.0 / 60.0 : 1.0)
            startTimer()
        }
    }
    
    private func tick() {
        guard timeRemaining > 0 else {
            timer?.cancel()
            if currentSessionIndex >= pomodoroSchedule.count {
                print("✅ Session complete notification sent.")
                NotificationManager.sendSessionCompleteNotification(isTestingMode: isTestingMode)
                print("🏁 Notifikasi sesi selesai berhasil dipicu.")
                stopTimer()
                return
            }
            if currentSession == .focus && !hasScheduledBreakNotification {
                sendHardBreakNotification()
                hasScheduledBreakNotification = true
                isBreakTimeTriggered = true
                isRunning = false
                timer?.cancel()
                timer = nil
                print("⏹️ Timer berhenti menunggu konfirmasi Start Break.")
                return
            }

            if currentSession == .longBreak {
                print("🛌 Memasuki long break.")
                NotificationManager.sendLongBreakNotification(isTestingMode: isTestingMode)
                print("💤 Long break notification triggered with sound and haptic.")
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
        
        if currentSession == .focus && !hasScheduledPreBreakNotification {
            if timeRemaining == 60 {
                hasScheduledPreBreakNotification = true
                print("🔔 SOFT NOTIFICATION: 1 minute remaining before break.")
                NotificationManager.scheduleSoftNotificationBeforeBreak(in: 1, isTestingMode: isTestingMode)

                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }
        }
        
        timeRemaining -= 1
    }
    
    func resetReturnFlag() {
        shouldReturnToRunningView = false
    }
    
    func shouldEnterBreak() -> Bool {
        guard let startedAt = startedAt else { return false }
        let duration = Date().timeIntervalSince(startedAt)
        return duration >= 300 // 5 menit
    }
    
    func setupPomodoroSchedule(totalDuration: TimeInterval) {
        var cycle = PomodoroCycle(totalDuration: totalDuration)
        cycle.focusDuration = selectedTime * testingMultiplier
        self.currentSessionDuration = selectedTime * testingMultiplier
        pomodoroSchedule = cycle.generateSchedule()
        currentSessionIndex = 0
        totalRemainingTime = totalDuration
    }
    
    func stopLoopingAlertSound() {
        AudioLoopManager.shared.stopLoopingSound()
        print("🔕 Looping sound stopped by user.")
    }
}


struct PomodoroCycle {
    var totalDuration: TimeInterval // total
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
        
        func defaultDuration(multiplier: Double = 1.0) -> TimeInterval {
            switch self {
            case .focus: return 25 * 60 * multiplier
            case .shortBreak: return 5 * 60 * multiplier
            case .longBreak: return 15 * 60 * multiplier
            }
        }
    }
}
