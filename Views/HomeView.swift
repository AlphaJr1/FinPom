import SwiftUI

struct HomeView: View {
    @ObservedObject var timerVM: TimerViewModel
    @State private var isNavigatingToRunning = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "E1F7FE"),
                        Color(hex: "F6F9FA")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    Spacer()

                    Text("Focus Timer")

                    Text(timeString(from: timerVM.selectedTime))
                        .font(.system(size: 64, weight: .bold, design: .default))
                        .padding(.top, 8)

                    NavigationLink(destination: SetTimerView(timerVM: timerVM)) {
                        Text("Set Timer >")
                            .foregroundColor(.primary)
                            .padding(.top, 4)
                    }

                    Spacer()

                    Button(action: {
                        print("Start Focus tapped")
                        print("Selected Time: \(timerVM.selectedTime)")

                        guard timerVM.selectedTime > 0 else {
                            print("Selected time is zero, skipping setup")
                            return
                        }

                        timerVM.setupPomodoroSchedule(totalDuration: timerVM.selectedTime)
                        print("Pomodoro schedule: \(timerVM.pomodoroSchedule)")
                        
                        if !timerVM.pomodoroSchedule.isEmpty {
                            timerVM.currentSessionIndex = 0
                            timerVM.timeRemaining = timerVM.selectedTime
                            timerVM.startTimer()
                            print("Timer started with timeRemaining: \(timerVM.timeRemaining)")
                            isNavigatingToRunning = true
                        } else {
                            print("No session scheduled, navigation not triggered")
                        }
                    }) {
                        Text("Start Focus")
                            .frame(minWidth: 160)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $isNavigatingToRunning) {
                    RunningTimerView()
                        .environmentObject(timerVM)
                }
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

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#") // remove # if exists

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    let timerVM = TimerViewModel()
    timerVM.selectedTime = 25 * 60
    timerVM.setupPomodoroSchedule(totalDuration: 25 * 60)
    return NavigationStack {
        HomeView(timerVM: timerVM)
    }
}
