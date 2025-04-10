import Foundation
import SwiftUI

struct RunningTimerView: View {
    @Environment(\.colorScheme) var colorScheme
    enum TimerState {
        case running
        case paused
        case stopped
    }

    @EnvironmentObject var timerVM: TimerViewModel
    @Environment(\.dismiss) var dismiss
    @State private var backgroundColor: Color = Color(.background)
    @State private var transitionID = UUID()
    @State private var isNavigatingToPause = false
    @State private var timerState: TimerState = .running
    @State private var isShowingBreakView = false
    @State private var isShowingCompletionAlert = false
    @State private var isCompletionAlertHandled = false
    @State private var isCustomBreakPromptShown = false

    var body: some View {
        buildTimerContent()
            .fullScreenCover(isPresented: $isShowingBreakView) {
                let currentIndex = timerVM.currentSessionIndex
                let schedule = timerVM.pomodoroSchedule
                let type: BreakView.BreakType = {
                    if schedule.indices.contains(currentIndex), schedule[currentIndex] == .shortBreak {
                        return .short
                    } else {
                        return .long
                    }
                }()

                BreakView(
                    breakType: type,
                    isShowingBreakView: $isShowingBreakView
                )
            }
    }

    private func buildTimerContent() -> some View {
        ZStack {
            timerBodyView()
        }
    }

    private func timerBodyView() -> some View {
        let needsAnimation: Bool = {
            if timerVM.currentSessionIndex < timerVM.pomodoroSchedule.count {
                return timerVM.pomodoroSchedule[timerVM.currentSessionIndex] != .focus
            }
            return false
        }()

        let base = backgroundColor
            .ignoresSafeArea()

        let animated = base
            .modifier(TransitionModifier(needsAnimation: needsAnimation, id: transitionID))

        let timerContent = VStack(spacing: 16) {
            Spacer()
            Text(sessionTitle())
                .foregroundColor(timerState == .running ? .white : (colorScheme == .dark ? .white : .black))
                .font(.system(size: 20))
                .padding(.top, 4)

            Text(timeString(from: timerVM.timeRemaining))
                .font(.system(size: 64, weight: .bold, design: .default))
                .foregroundColor(timerState == .running ? .white : (colorScheme == .dark ? .white : .black))
                .padding(.top, 8)

            Spacer()
            controlButtons()
            Spacer()
        }
        .padding()
        .onAppear {
            NotificationManager.requestAuthorization()

            if timerVM.shouldResumeAfterPause {
                DispatchQueue.main.async {
                    timerVM.resumeTimer()
                    timerVM.shouldResumeAfterPause = false
                }
            }

            transitionID = UUID()
            guard !timerVM.pomodoroSchedule.isEmpty,
                  timerVM.currentSessionIndex < timerVM.pomodoroSchedule.count else {
                dismiss()
                return
            }

            let currentSession = timerVM.pomodoroSchedule[timerVM.currentSessionIndex]
            if currentSession == .focus {
                startCurrentSession()
                backgroundColor = Color.background

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UNUserNotificationCenter.current().getNotificationSettings { settings in
                        if settings.authorizationStatus == .authorized {
                            let safeTime = max(5, min(60, timerVM.timeRemaining - 5))
                            NotificationManager.scheduleSoftNotificationBeforeBreak(in: safeTime, isTestingMode: timerVM.isTestingMode)
                            NotificationManager.scheduleHardNotification(
                                title: "⏸️ Break Time!",
                                body: "Nice focus! Time to rest for a bit. 🎧",
                                inSeconds: timerVM.timeRemaining,
                                identifier: "HARD_NOTIFICATION",
                                sound: .defaultCritical,
                                isCritical: true,
                                isTestingMode: timerVM.isTestingMode
                            )
                            print("🔔 Notifications scheduled: soft=\(safeTime), hard=\(timerVM.timeRemaining)")
                        } else {
                            print("⚠️ Notification permission not granted.")
                        }
                    }
                }
            }
        }
        .onChange(of: timerVM.timeRemaining) {
            let newValue = timerVM.timeRemaining
            if newValue <= 0 && !isCompletionAlertHandled {
                isCompletionAlertHandled = true

                _ = timerVM.pomodoroSchedule.indices.contains(timerVM.currentSessionIndex + 1)
                    ? timerVM.pomodoroSchedule[timerVM.currentSessionIndex + 1]
                    : nil

                if timerVM.pomodoroSchedule[timerVM.currentSessionIndex] == .focus {
                    isCustomBreakPromptShown = true
                    AudioLoopManager.shared.startLoopingSound()
                } else if timerVM.pomodoroSchedule[timerVM.currentSessionIndex] != .focus {
                    isCustomBreakPromptShown = true
                }
            }
        }
        .onChange(of: timerVM.isBreakTimeTriggered) {
            let newValue = timerVM.isBreakTimeTriggered
            if newValue {
            }
        }

        let overlay1 = animated.overlay(timerContent)

        let finalView = overlay1.overlay(
            Group {
                if isCustomBreakPromptShown {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        VStack(spacing: 16) {
                            Text("🎉 Great Job!")
                                .font(.title)
                                .bold()
                                .foregroundColor(.primary)

                            Text("You’ve completed your focus session.\nTime for a well-deserved break!")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)

                            Button("Start Break") {
                                print("[Overlay] Start Break pressed")
                                AudioLoopManager.shared.stopLoopingSound()
                                isCustomBreakPromptShown = false
                                isShowingBreakView = true
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.fromHex("#0077B6"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                    }
                }
            }
        )

        return finalView
    }

    private func controlButtons() -> some View {
        return HStack(spacing: 16) {
            FinPomButton(
                title: timerState == .paused ? "Resume" : "Pause",
                backgroundColor: timerState == .paused ? Color.background : Color.fromHex("#FFD166"),
                foregroundColor: timerState == .paused ? .white : .black,
                action: {
                    if timerState == .paused {
                        timerVM.resumeTimer()
                        timerState = .running
                        backgroundColor = Color.background
                    } else {
                        timerVM.pauseTimer()
                        timerState = .paused
                        backgroundColor = colorScheme == .dark ? .black : .white
                    }
                }
            )

            FinPomButton(
                title: "Stop",
                backgroundColor: Color.fromHex("#FF6B6B"),
                foregroundColor: .white,
                action: {
                    timerVM.stopTimer()
                    dismiss()
                }
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }

    private func sessionTitle() -> String {
        guard timerVM.currentSessionIndex < timerVM.pomodoroSchedule.count else {
            return "Session Ended"
        }

        switch timerVM.pomodoroSchedule[timerVM.currentSessionIndex] {
        case .focus:
            return "Focus Timer"
        case .shortBreak:
            return "Short Break Timer"
        case .longBreak:
            return "Long Break Timer"
        }
    }

    private func startCurrentSession() {
        guard timerVM.currentSessionIndex < timerVM.pomodoroSchedule.count else {
            dismiss()
            return
        }

        let session = timerVM.pomodoroSchedule[timerVM.currentSessionIndex]
        let backgroundColor: Color

        switch session {
        case .focus:
            backgroundColor = Color.fromHex("#0077B6")
            timerVM.timeRemaining = timerVM.selectedTime
        case .shortBreak:
            backgroundColor = .green.opacity(0.2)
            timerVM.timeRemaining = 300
        case .longBreak:
            backgroundColor = .blue.opacity(0.2)
            timerVM.timeRemaining = 900
        }
        timerState = .running
        timerVM.startTimer()
        isCompletionAlertHandled = false

        withAnimation {
            self.backgroundColor = backgroundColor
        }
        
        HapticsManager.shared.lightImpact()
    }

    private func nextSession() {
        timerVM.stopTimer()
        timerVM.currentSessionIndex += 1

        if timerVM.currentSessionIndex >= timerVM.pomodoroSchedule.count {
            print("All sessions completed.")
            dismiss()
        } else {
            timerVM.totalRemainingTime -= timerVM.selectedTime
            let nextSession = timerVM.pomodoroSchedule[timerVM.currentSessionIndex]

            if nextSession == .shortBreak || nextSession == .longBreak {
                isCustomBreakPromptShown = true
                AudioLoopManager.shared.startLoopingSound()
            } else {
                startCurrentSession()
            }
        }
    }

    private func timeString(from time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

private struct TransitionModifier: ViewModifier {
    let needsAnimation: Bool
    let id: UUID

    func body(content: Content) -> some View {
        if needsAnimation {
            return AnyView(
                content
                    .transition(.opacity.combined(with: .scale))
                    .animation(.easeInOut(duration: 0.5), value: id)
            )
        } else {
            return AnyView(
                content
                    .transition(.opacity.combined(with: .scale))
            )
        }
    }
}

#Preview {
    let timerVM = TimerViewModel()
    timerVM.selectedTime = 25 * 60
    timerVM.timeRemaining = 25 * 60
    timerVM.pomodoroSchedule = [.focus, .shortBreak, .focus]
    timerVM.currentSessionIndex = 0

    return RunningTimerView()
        .environmentObject(timerVM)
}
