import Foundation
import UIKit
import AudioToolbox

class HapticsManager {
    static let shared = HapticsManager()
    
    private var soundTimer: Timer?

    private init() {}

    // Light impact (e.g., soft alert)
    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    // Medium impact (e.g., normal tap)
    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    // Heavy impact (e.g., strong feedback)
    func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    // Notification feedback (success, warning, error)
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    // System vibration (long)
    func vibrateHard() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func startRepeatingSystemSound() {
        stopRepeatingSystemSound() // Pastikan hanya satu timer berjalan
        soundTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            AudioServicesPlaySystemSound(1005) // Suara sistem keras seperti di notifikasi
            self.vibrateHard()
            print("[HapticsManager] Playing repeating alert sound + vibration")
        }
    }
    
    func stopRepeatingSystemSound() {
        soundTimer?.invalidate()
        soundTimer = nil
        print("[HapticsManager] Stopped repeating alert sound")
    }
}
