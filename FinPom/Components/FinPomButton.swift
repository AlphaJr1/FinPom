//
//  FinPomButton.swift
//  FinPom
//
//  Created by Adrian Alfajri on 03/04/25.
//

import SwiftUI

struct FinPomButton: View {
    var title: String
    var backgroundColor: Color
    var foregroundColor: Color = .white
    var action: () -> Void
    var onLongPress: (() -> Void)? = nil
    
    @State private var isPressing = false

    var body: some View {
        ZStack {
            if title == "Pause Focus" && isPressing {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 4)
                    .frame(maxWidth: isPressing ? .infinity : 0, alignment: .leading)
                    .animation(.linear(duration: 2.0), value: isPressing)
                    .padding(.horizontal, 24)
                    .offset(y: 35) // sedikit di bawah tombol
            }

            Button(action: action) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(foregroundColor)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(isPressing && title == "Pause Focus" ? Color.red.opacity(0.8) : backgroundColor)
                    .cornerRadius(12)
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 2.0)
                    .onChanged { _ in
                        if title == "Pause Focus" {
                            isPressing = true
                        }
                    }
                    .onEnded { _ in
                        print("🔒 Long press gesture detected. Triggering haptic...")
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onLongPress?()
                        isPressing = false
                    }
            )
        }
    }
}

struct FinPomButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FinPomButton(
                title: "Start Focus",
                backgroundColor: .blue,
                action: { print("Tapped Start") },
                onLongPress: { print("Session Cancelled") }
            )
            FinPomButton(
                title: "Pause Focus",
                backgroundColor: .red,
                action: { print("Paused") }
            )
            FinPomButton(
                title: "Resume Focus",
                backgroundColor: .fromHex("#FFD166"),
                foregroundColor: .black,
                action: { print("Resumed") },
                onLongPress: { print("Session Cancelled") }
            )
        }
        .padding()
    }
}

extension Color {
    static func fromHex(_ hex: String) -> Color {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        return Color(red: r, green: g, blue: b)
    }
}
