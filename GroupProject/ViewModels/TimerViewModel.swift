import Foundation

enum PomodoroMode: String {
    case work = "Work"
    case breakTime = "Break"
    case idle = "Idle"
}

final class TimerViewModel: ObservableObject {
    @Published var timerDisplay: String = "0:00"
    @Published var currentMode: PomodoroMode = .idle
    
    @Published var currentStreak: Int = 0
    @Published var overallStreak: Int = 0

    private let timer: PomodoroTimer

    init(timer: PomodoroTimer) {
        self.timer = timer

        self.timer.onTick = { [weak self] formattedTime in
            DispatchQueue.main.async {
                self?.timerDisplay = formattedTime
            }
        }

        self.timer.onModeChange = { [weak self] modeDescription in
            DispatchQueue.main.async {
                self?.currentMode = modeDescription.contains("Work") ? .work : .breakTime
            }
        }

        self.timer.onStreakUpdate = { [weak self] currentStreak, overallStreak in
            DispatchQueue.main.async {
                self?.currentStreak = currentStreak
                self?.overallStreak = overallStreak
            }
        }
    }

    func start() {
        timer.start()
    }

    func pause() {
        timer.pause()
    }

    func stop() {
        timer.stop()
    }
}
