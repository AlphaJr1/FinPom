//
//  FinPomTests.swift
//  FinPomTests
//
//  Created by Adrian Alfajri on 21/03/25.
//

import XCTest
@testable import FinPom

final class TimerViewModelTests: XCTestCase {

    func testStartTimerInitializesCorrectly() {
        let viewModel = TimerViewModel()
        viewModel.selectedTime = 10 // 10 detik

        viewModel.startTimer()

        XCTAssertTrue(viewModel.isRunning)
        XCTAssertFalse(viewModel.isPaused)
        XCTAssertEqual(viewModel.timeRemaining, 10)
        XCTAssertNotNil(viewModel.startedAt)
    }

    func testPauseAndResumeTimer() {
        let viewModel = TimerViewModel()
        viewModel.selectedTime = 60
        viewModel.startTimer()
        viewModel.pauseTimer()

        XCTAssertTrue(viewModel.isPaused)
        XCTAssertFalse(viewModel.isRunning)

        viewModel.resumeTimer()

        XCTAssertTrue(viewModel.isRunning)
        XCTAssertFalse(viewModel.isPaused)
    }

    func testStopTimerResetsState() {
        let viewModel = TimerViewModel()
        viewModel.selectedTime = 20
        viewModel.startTimer()
        viewModel.stopTimer()

        XCTAssertFalse(viewModel.isRunning)
        XCTAssertFalse(viewModel.isPaused)
        XCTAssertEqual(viewModel.timeRemaining, 20)
    }

    func testShouldEnterBreakReturnsTrueAfter5Minutes() {
        let viewModel = TimerViewModel()
        viewModel.startedAt = Date(timeIntervalSinceNow: -301) // 5+ menit lalu
        XCTAssertTrue(viewModel.shouldEnterBreak())
    }

    func testShouldEnterBreakReturnsFalseBefore5Minutes() {
        let viewModel = TimerViewModel()
        viewModel.startedAt = Date(timeIntervalSinceNow: -100) // <5 menit
        XCTAssertFalse(viewModel.shouldEnterBreak())
    }
}
