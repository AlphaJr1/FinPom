//
//  NotificationManager.swift
//  FinPom
//
//  Created by Adrian Alfajri on 07/04/25.
//

import Foundation
import UserNotifications
import CoreHaptics
import SwiftUI

struct NotificationManager {
    private static func triggerHaptic(_ style: String) {
        switch style {
        case "soft":
            print("📳 Haptic triggered: soft")
            HapticsManager.shared.lightImpact()
        case "hard":
            print("📳 Haptic triggered: hard")
            HapticsManager.shared.vibrateHard()
            HapticsManager.shared.vibrateHard() // Strengthened haptic feedback
        default:
            break
        }
    }

    static func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            } else {
                print(granted ? "✅ Notification permission granted." : "⚠️ Notification permission denied.")
            }
        }
    }

    static func sendBreakNotification(isTestingMode: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = "⏸️ Break Time!"
        content.body = "Nice focus! Time to rest for a bit. 🎧"
        content.sound = UNNotificationSound.defaultCritical // Fallback to defaultCritical
        content.categoryIdentifier = "BREAK_NOTIFICATION"
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: isTestingMode ? 0.1 : 2, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        print("📣 Scheduling break notification...")
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule break notification: \(error.localizedDescription)")
            } else {
                print("✅ Break notification scheduled.")
            }
        }
        triggerHaptic("hard")
        print("🔔 Memicu notifikasi break keras dengan suara dan getaran...")
        print("📣 Break notification sent.")
    }

    static func sendSessionCompleteNotification(isTestingMode: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = "✅ Focus Session Complete!"
        content.body = "Great job! You’ve completed all your Pomodoro sessions 🎉"
        content.sound = UNNotificationSound.defaultCritical // Fallback to defaultCritical
        content.interruptionLevel = .active
        content.categoryIdentifier = "SESSION_COMPLETE_NOTIFICATION"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: isTestingMode ? 0.1 : 2, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        print("📣 Scheduling session complete notification...")
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule session complete notification: \(error.localizedDescription)")
            } else {
                print("✅ Session complete notification scheduled.")
            }
        }
        triggerHaptic("hard")
        print("📢 Notifikasi sesi selesai telah dipicu.")
        print("🏁 Session complete notification sent.")
    }

    static func sendLongBreakNotification(isTestingMode: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = "🛌 Long Break Time!"
        content.body = "You've earned a longer rest. Take a full break! 🌿"
        content.sound = UNNotificationSound.defaultCritical // Fallback to defaultCritical
        content.categoryIdentifier = "BREAK_NOTIFICATION"
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: isTestingMode ? 0.1 : 2, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        print("📣 Scheduling long break notification...")
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule long break notification: \(error.localizedDescription)")
            } else {
                print("✅ Long break notification scheduled.")
            }
        }
        triggerHaptic("hard")
        print("📢 Notifikasi long break keras dipicu.")
        print("😴 Long break notification sent.")
    }
    
    static func scheduleSoftNotificationBeforeBreak(in seconds: TimeInterval, identifier: String = "SOFT_NOTIFICATION", isTestingMode: Bool = false) {
        guard seconds >= 1 else {
            print("⚠️ Soft notification skipped: interval too short (\(seconds) sec)")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "🔔 One Minute Left"
        content.body = "Get ready, your break is about to begin!"
        content.sound = nil
        content.interruptionLevel = .active
        content.categoryIdentifier = identifier

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: isTestingMode ? seconds / 60 : seconds, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        print("📣 Scheduling soft notification before break in \(seconds) seconds...")

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule soft notification: \(error.localizedDescription)")
            } else {
                print("🔔 Soft notification successfully scheduled.")
            }
        }

        triggerHaptic("soft")
    }
    
    static func scheduleHardNotification(title: String, body: String, inSeconds: TimeInterval, identifier: String = "HARD_NOTIFICATION", sound: UNNotificationSound = .defaultCritical, isCritical: Bool = true, isTestingMode: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        content.interruptionLevel = .critical
        content.categoryIdentifier = identifier

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: isTestingMode ? inSeconds / 60 : inSeconds, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        print("📣 Scheduling hard notification '\(identifier)' in \(inSeconds) seconds...")

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule hard notification: \(error.localizedDescription)")
            } else {
                print("📢 Hard notification '\(identifier)' scheduled.")
            }
        }

        triggerHaptic("hard")
    }
}
