//
//  RunningTimerView.swift
//  FinPom
//
//  Created by Adrian Alfajri on 03/04/25.
//

import SwiftUI

struct RunningTimerView: View {
    @EnvironmentObject var timerVM: TimerViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text(sessionTitle())
                .font(.title)

            Text(timeString(from: timerVM.timeRemaining))
                .font(.system(size: 60, weight: .semibold, design: .monospaced))
                .padding()

            Text("Remaining: \(timeString(from: timerVM.totalRemainingTime))")
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack(spacing: 30) {
                Button(timerVM.isRunning ? "Pause" : "Resume") {
                    if timerVM.isRunning {
                        timerVM.pauseTimer()
                    } else {
                        timerVM.resumeTimer()
                    }
                }
                .foregroundColor(.blue)

                Button("Skip") {
                    nextSession()
                }
                .foregroundColor(.red)
            }
        }
        .onAppear {
            guard !timerVM.pomodoroSchedule.isEmpty,
                  timerVM.currentSessionIndex < timerVM.pomodoroSchedule.count else {
                dismiss()
                return
            }
            startCurrentSession()
        }
        .onChange(of: timerVM.timeRemaining) { newValue in
            if newValue <= 0 {
                nextSession()
            }
        }
        .padding()
    }

    private func sessionTitle() -> String {
        guard timerVM.currentSessionIndex < timerVM.pomodoroSchedule.count else {
            return "Session Ended"
        }

        switch timerVM.pomodoroSchedule[timerVM.currentSessionIndex] {
        case .focus:
            return "Focus Session"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }

    private func startCurrentSession() {
        guard timerVM.currentSessionIndex < timerVM.pomodoroSchedule.count else {
            dismiss()
            return
        }

        let session = timerVM.pomodoroSchedule[timerVM.currentSessionIndex]

        switch session {
        case .focus:
            timerVM.selectedTime = 25 * 60
        case .shortBreak:
            timerVM.selectedTime = 5 * 60
        case .longBreak:
            timerVM.selectedTime = 15 * 60
        }

        timerVM.timeRemaining = timerVM.selectedTime
        timerVM.startTimer()
    }

    private func nextSession() {
        timerVM.stopTimer()
        timerVM.currentSessionIndex += 1

        if timerVM.currentSessionIndex >= timerVM.pomodoroSchedule.count {
            dismiss()
        } else {
            // timerVM.totalRemainingTime -= timerVM.selectedTime // dihilangkan sementara
            startCurrentSession()
        }
    }

    private func timeString(from time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    let timerVM = TimerViewModel()
    timerVM.selectedTime = 25 * 60
    timerVM.setupPomodoroSchedule(totalDuration: 25 * 60)
    return NavigationStack {
        RunningTimerView()
            .environmentObject(timerVM)
    }
}
