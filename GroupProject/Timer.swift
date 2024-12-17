import Foundation
import UIKit

class TextTimer {
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var startTime: Date?
    private var elapsedTime: TimeInterval = 0
    private var pausedElapsedTime: TimeInterval = 0
    
    private(set) var timerRunning: Bool = false
    
    // callback with formatted time update
    var onTick: ((String) -> Void)?
    /// start either from pause or scratch
    func start(withInterval interval: TimeInterval) {
            if timerRunning { return }

            timerRunning = true
            
            if startTime == nil { // fresh start
                startTime = Date()
            } else { // resume from pause
                startTime = Date().addingTimeInterval(-pausedElapsedTime)
            }
        
        // actual timer
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            if let strongSelf = self, let start = strongSelf.startTime {
                strongSelf.elapsedTime = Date().timeIntervalSince(start)
                let formattedTime = strongSelf.formatElapsedTime(strongSelf.elapsedTime)
                strongSelf.onTick?(formattedTime)
            }
        }
        
        beginBackgroundTask()
    }
    /// stop without reset
    func pause() {
        if !timerRunning { return }

        timerRunning = false
        timer?.invalidate()
        timer = nil
        endBackgroundTask()
    }
    /// stop and reset
    func stop() {
        timerRunning = false
        timer?.invalidate()
        timer = nil
        startTime = nil
        pausedElapsedTime = 0
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
}
