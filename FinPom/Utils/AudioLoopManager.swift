//
//  AudioLoopManager.swift
//  FinPom
//
//  Created by Adrian Alfajri on 09/04/25.
//

import Foundation
import AVFoundation

class AudioLoopManager {
    static let shared = AudioLoopManager()
    private var player: AVAudioPlayer?
    private var isPlaying = false

    func startLoopingSound(named soundName: String? = nil) {
        if let name = soundName {
            // Try using a custom-named bundled file
            if let url = Bundle.main.url(forResource: name, withExtension: "caf") ?? Bundle.main.url(forResource: name, withExtension: "mp3") {
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                    player?.numberOfLoops = -1
                    player?.prepareToPlay()
                    player?.play()
                    isPlaying = true
                    print("🔁 Looping bundled audio '\(name)' started.")
                    return
                } catch {
                    print("⚠️ Failed to load bundled audio '\(name)': \(error)")
                }
            }
        }

        // Default: Try system sound
        if let url = URL(string: "/System/Library/Audio/UISounds/alarm.caf") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = -1 // loop indefinitely
                player?.prepareToPlay()
                player?.play()
                isPlaying = true
                print("🔁 Looping default system audio started.")
                return
            } catch {
                print("⚠️ Failed to load system sound. Trying fallback...")
            }
        }

        // Fallback bundled file
        if let fallbackURL = Bundle.main.url(forResource: "alarm", withExtension: "caf") {
            do {
                player = try AVAudioPlayer(contentsOf: fallbackURL)
                player?.numberOfLoops = -1
                player?.prepareToPlay()
                player?.play()
                isPlaying = true
                print("🔁 Looping fallback audio started.")
            } catch {
                print("❌ Failed to load fallback audio: \(error)")
            }
        } else {
            print("❌ No audio file found to loop.")
        }
    }

    func stopLoopingSound() {
        guard isPlaying else { return }
        player?.stop()
        isPlaying = false
        print("⏹️ Looping audio stopped.")
    }

    func isSoundPlaying() -> Bool {
        return isPlaying
    }
}

