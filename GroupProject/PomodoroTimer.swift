import Foundation

class PomodoroTimer {
    private let textTimer = TextTimer()
    private var workDuration: TimeInterval = 45 * 60
    private var breakDuration: TimeInterval = 15 * 60
    private var isWorkMode: Bool = true
    
    private(set) var currentStreak: Int = 0
    private(set) var overallStreak: Int = 0
    
    var onTick: ((String) -> Void)?
    var onModeChange: ((String) -> Void)?
    var onStreakUpdate: ((Int, Int) -> Void)? // (currentStreak, overallStreak)
    
    init() {
        textTimer.onTick = { [weak self] formattedTime in
            self?.onTick?(formattedTime)
        }
    }
    
    /// Start the Pomodoro timer
    func start() {
        startCycle()
    }
    
    /// Pause the Pomodoro timer
    func pause() {
        textTimer.pause()
        onModeChange?("Timer paused")
    }
    
    /// Stop and reset the Pomodoro timer
    func stop() {
        textTimer.stop()
        currentStreak = 0
        isWorkMode = true
        onModeChange?("Timer stopped. Current streak reset.")
        onStreakUpdate?(currentStreak, overallStreak)
    }
    
    private func startCycle() {
        let duration = isWorkMode ? workDuration : breakDuration
        let modeText = isWorkMode ? "Work Session Started" : "Break Session Started"
        onModeChange?(modeText)
        
        textTimer.onTick = { [weak self] formattedTime in
            self?.onTick?(formattedTime)
        }
        
        textTimer.start(withInterval: 1.0)
        
        // Schedule the end of the cycle
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            self?.finishCycle()
        }
    }
    
    private func finishCycle() {
        textTimer.stop()
        
        if isWorkMode {
            currentStreak += 1
            overallStreak += 1
            onModeChange?("Work Session Complete! Time for a break.")
        } else {
            onModeChange?("Break Complete! Time to work.")
        }
        onStreakUpdate?(currentStreak, overallStreak)
        
        // Switch modes
        isWorkMode.toggle()
        startCycle()
    }
}

// It is here because I don`t want to wait whole hour to complete the tests
#if DEBUG
extension PomodoroTimer {
    public func exposeStartCycle() {
        self.startCycle()
    }
    
    public func exposeFinishCycle() {
        self.finishCycle()
    }
}
#endif
