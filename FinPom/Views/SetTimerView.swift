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

    @State private var selectedHour = 0
    @State private var selectedMinute = 25
    @State private var selectedSecond = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Focus Time")
                .font(.headline)

            VStack {
                HStack(spacing: 0) {
                    Picker("", selection: $selectedHour) {
                        ForEach(0...8, id: \.self) { Text("\($0) h") }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    Picker("", selection: $selectedMinute) {
                        ForEach(Array(stride(from: 10, through: 55, by: 5)), id: \.self) { Text("\($0) m") }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    Picker("", selection: $selectedSecond) {
                        ForEach([0, 15, 30, 45], id: \.self) { Text("\($0) s") }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                }
                .pickerStyle(.wheel)
            }

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.red)

                Spacer()

                Button("Done") {
                    // Simpan waktu ke TimerViewModel
                    let totalSeconds = TimeInterval((selectedHour * 3600) + (selectedMinute * 60) + selectedSecond)
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
