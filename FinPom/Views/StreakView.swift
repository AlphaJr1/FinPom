//  StreakView.swift
//  FinPom
//
//  Created by Ali Jazzy Rasyid on 21/03/25.
//

import SwiftUI
import Charts

struct FocusTime: Identifiable {
    let id = UUID()
    let day: String
    let minutes: Int
}

struct FocusBreakData: Identifiable {
    let id = UUID()
    let day: String
    let focusMinutes: Int
    let breakMinutes: Int
}

// Sample Data
let focusData: [FocusTime] = [
    FocusTime(day: "Mon", minutes: 30),
    FocusTime(day: "Tue", minutes: 45),
    FocusTime(day: "Wed", minutes: 25),
    FocusTime(day: "Thu", minutes: 40),
    FocusTime(day: "Fri", minutes: 50),
    FocusTime(day: "Sat", minutes: 20),
    FocusTime(day: "Sun", minutes: 35)
]

let historyData: [FocusBreakData] = [
    FocusBreakData(day: "Mon", focusMinutes: 30, breakMinutes: 10),
    FocusBreakData(day: "Tue", focusMinutes: 45, breakMinutes: 15),
    FocusBreakData(day: "Wed", focusMinutes: 25, breakMinutes: 10),
    FocusBreakData(day: "Thu", focusMinutes: 40, breakMinutes: 20),
    FocusBreakData(day: "Fri", focusMinutes: 50, breakMinutes: 25),
    FocusBreakData(day: "Sat", focusMinutes: 20, breakMinutes: 5),
    FocusBreakData(day: "Sun", focusMinutes: 35, breakMinutes: 10)
]

// Calculate Average
let averageMinutes = focusData.map { $0.minutes }.reduce(0, +) / focusData.count

struct StreakView: View {
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        streakContent
    }
    
    private var streakContent: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    streakCard
                    focusTimeSection
                    focusBreakHistory
                }
                .padding()
            }
            .background(Color(red: 0.0, green: 0.47, blue: 0.71))
            .navigationTitle("Activities")
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .tint(Color.black)
    }
    
    private var streakCard: some View {
        HStack(spacing: 15) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
                .font(.system(size: 40))
            
            VStack(alignment: .leading) {
                Text("Streak!")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.red)
                Text("5 Days")
                    .font(.title2)
                    .fontWeight(.bold)
            }
            Spacer()
            Text("Keep going\nyou can do it!")
                .font(.body)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 120)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
    
    private var focusTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("⏱️ Focus Time")
                .font(.title3)
                .bold()
            
            Text("You've spent 20 minutes more than last week!")
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            
            // 📅 Focus Time Stats
            HStack {
                VStack(alignment: .leading) {
                    Text("Today")
                        .font(.body)
                        .foregroundStyle(Color.orange)
                    Text("20 Minutes")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Average")
                        .font(.body)
                    Text("\(averageMinutes) Minutes")
                        .font(.title2)
                        .fontWeight(.bold)
                }
            }
            
            // 📊 Weekly Focus Time Chart
            Chart(focusData) { day in
                BarMark(
                    x: .value("Day", day.day),
                    y: .value("Minutes", day.minutes)
                )
                .foregroundStyle(Color.gray) // Bar Color
                
                // 📏 RuleMark for Average Line
                RuleMark(y: .value("Average", averageMinutes))
                    .foregroundStyle(Color.dangerColor)
                    .annotation(position: .bottom, alignment: .bottomLeading) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.dangerColor.opacity(0.8))
                                .frame(width: 60, height: 20)
                            Text("Avg: \(averageMinutes)")
                                .fontWeight(.black)
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }
            }
            .frame(height: 150)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
    
    private var focusBreakHistory: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📅 Focus History")
                .font(.title3)
                .bold()
            
            ForEach(historyData) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(entry.day)
                        .fontWeight(.semibold)

                    ProgressBarView(focusMinutes: entry.focusMinutes, breakMinutes: entry.breakMinutes)
                    
                    HStack {
                        Text("\(entry.focusMinutes) min focus")
                            .foregroundColor(.blue)
                        Spacer()
                        Text("+ \(entry.breakMinutes) min break")
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

struct ProgressBarView: View {
    let focusMinutes: Int
    let breakMinutes: Int

    var body: some View {
        let totalMinutes = max(focusMinutes + breakMinutes, 1)
        let focusRatio = CGFloat(focusMinutes) / CGFloat(totalMinutes)

        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background (Break Time)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.dangerColor.opacity(0.3))
                    .frame(height: 20)

                // Foreground (Focus Time)
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue)
                    .frame(width: geo.size.width * focusRatio, height: 20)
            }
        }
        .frame(height: 20)
    }
}

extension Color {
    static let dangerColor = Color(red: 1.0, green: 0.27, blue: 0.23)
}

#Preview {
    StreakView()
}
