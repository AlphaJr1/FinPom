//
//  SetTimerView.swift
//  FinPom
//
//  Created by Adrian Alfajri on 03/04/25.
//

import SwiftUI

struct SetTimerView: View {
    @ObservedObject var timerVM: TimerViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedDate = Date()

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Focus Time")
                .font(.headline)

            DatePicker(
                "",
                selection: $selectedDate,
                displayedComponents: [.hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.red)

                Spacer()

                Button("Done") {
                    // Simpan waktu ke TimerViewModel
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.hour, .minute], from: selectedDate)
                    let hours = components.hour ?? 0
                    let minutes = components.minute ?? 0
                    let totalSeconds = TimeInterval((hours * 60 + minutes) * 60)
                    timerVM.selectedTime = totalSeconds
                    timerVM.timeRemaining = totalSeconds
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        SetTimerView(timerVM: TimerViewModel())
    }
}
