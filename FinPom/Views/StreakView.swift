//  StreakView.swift
//  FinPom
//
//  Created by Ali Jazzy Rasyid on 21/03/25.
//

import SwiftUI
import Charts


struct FocusData: Identifiable {
    let id = UUID()
    let day: String
    let focus: CGFloat
    let breakTime: CGFloat
}

struct StreakView: View {
    let data: [FocusData] = [
        .init(day: "Mon", focus: 50, breakTime: 25),
        .init(day: "Tue", focus: 45, breakTime: 25),
        .init(day: "Wed", focus: 50, breakTime: 25),
        .init(day: "Thu", focus: 45, breakTime: 25),
        .init(day: "Fri", focus: 50, breakTime: 25),
        .init(day: "Sat", focus: 55, breakTime: 25),
        .init(day: "Sun", focus: 55, breakTime: 25),
    ]
    
    let maxMinutes: CGFloat = 60

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    streakCard
                    focusTimeSection
                }
                .padding()
            }
            .background(Color(red: 0.0, green: 0.47, blue: 0.71))
            .navigationTitle("Activities")
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .tint(Color.primary)
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
        .cornerRadius(16)
        .shadow(radius: 3)
    }

    private var focusTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("⏱️ Focus Time")
                    .font(.headline)
                Spacer()
            }

            Text("Every bar you see is proof that you’re staying committed to your goals, one day at a time. Your average time tells your discipline story.")
                .font(.caption)
                .fontWeight(.regular)

            HStack {
                VStack(alignment: .leading) {
                    Text("Focus")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("20 Minutes")
                        .font(.headline)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Break")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("35 Minutes")
                        .font(.headline)
                }
            }

            // 📊 Bar Chart
            HStack(alignment: .bottom, spacing: 24) {
                ForEach(data) { item in
                    VStack {
                        HStack(alignment: .bottom, spacing: 4) {
                            Capsule()
                                .fill(Color.blue)
                                .frame(width: 12, height: (item.focus / maxMinutes) * 100)
                            
                            Capsule()
                                .fill(Color.red)
                                .frame(width: 12, height: (item.breakTime / maxMinutes) * 100)
                        }

                        Text(item.day)
                            .font(.caption2)
                    }
                }
            }
            .frame(height: 120)

            // 🔹 Legend
            HStack(spacing: 30) {
                HStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    Text("Focus")
                        .font(.caption)
                }
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("Break")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

#Preview {
    
        StreakView().preferredColorScheme(.dark)
    }

