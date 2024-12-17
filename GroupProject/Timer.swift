import Foundation
import UIKit

// https://medium.com/codex/a-simple-swift-background-timer-bebd36589203
// https://www.hackingwithswift.com/forums/swiftui/how-to-make-timer-continue-working-in-background/7479
// https://www.hackingwithswift.com/books/ios-swiftui/counting-down-with-a-timer
class TextTimer {
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var startTime: Date?
    private var elapsedTime: TimeInterval = 0
    private var pausedElapsedTime: TimeInterval = 0

    private(set) var timerRunning: Bool = false

    // Callback with formatted time update
    var onTick: ((String) -> Void)?

    /// Start either from pause or scratch
    func start(withInterval interval: TimeInterval) {
        if timerRunning { return }
        timerRunning = true

        if startTime == nil { // Fresh start
            startTime = Date()
        } else { // Resume
            startTime = Date().addingTimeInterval(-pausedElapsedTime)
        }

        // Actual timer
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [unowned self] _ in
            if let start = self.startTime {
                self.elapsedTime = Date().timeIntervalSince(start)
                let formattedTime = self.formatElapsedTime(self.elapsedTime)
                self.onTick?(formattedTime)
            }
        }

        beginBackgroundTask()
    }

    /// Pause without resetting the elapsed time
    func pause() {
        if !timerRunning { return }
        timerRunning = false

        if let start = startTime {
            pausedElapsedTime = Date().timeIntervalSince(start)  // Save elapsed time
        }

        timer?.invalidate()
        timer = nil
        endBackgroundTask()
    }

    /// Stop and reset
    func stop() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
        startTime = nil
        pausedElapsedTime = 0
        elapsedTime = 0
        onTick?("0:00")
        endBackgroundTask()
    }

    private func formatElapsedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func beginBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "BackgroundTimer") {
            self.endBackgroundTask()
        }
    }

    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    deinit {
        timer?.invalidate()
        endBackgroundTask()
    }
}
