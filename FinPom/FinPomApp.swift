//
//  FinPomApp.swift
//  FinPom
//
//  Created by Adrian Alfajri on 21/03/25.
//

import SwiftUI
import Foundation

@main
struct FinPomApp: App {
    @StateObject var timerVM = TimerViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView(timerVM: timerVM)
            }
        }
    }
}
