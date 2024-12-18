import UIKit
import SnapKit

class TimerViewController: UIViewController {
    
    private let timerLabel = UILabel()
    private let startButton = UIButton(type: .system)
    private let pauseButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let modeLabel = UILabel()
    
    private let pomodoroTimer = PomodoroTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTimerCallbacks()
        hideKeyboardWhenTappedAround()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Pomodoro Timer"
        
        timerLabel.text = "25:00"
        timerLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        timerLabel.textAlignment = .center
        view.addSubview(timerLabel)
        timerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(100)
            make.centerX.equalToSuperview()
        }
        
        modeLabel.text = "Work"
        modeLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        modeLabel.textAlignment = .center
        view.addSubview(modeLabel)
        modeLabel.snp.makeConstraints { make in
            make.top.equalTo(timerLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = .systemGreen
        startButton.layer.cornerRadius = 8
        startButton.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        view.addSubview(startButton)
        
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.setTitleColor(.white, for: .normal)
        pauseButton.backgroundColor = .systemOrange
        pauseButton.layer.cornerRadius = 8
        pauseButton.addTarget(self, action: #selector(pauseTimer), for: .touchUpInside)
        view.addSubview(pauseButton)
        
        stopButton.setTitle("Stop", for: .normal)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.backgroundColor = .systemRed
        stopButton.layer.cornerRadius = 8
        stopButton.addTarget(self, action: #selector(stopTimer), for: .touchUpInside)
        view.addSubview(stopButton)
        
        let buttonStack = UIStackView(arrangedSubviews: [startButton, pauseButton, stopButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 20
        buttonStack.distribution = .fillEqually
        view.addSubview(buttonStack)
        buttonStack.snp.makeConstraints { make in
            make.top.equalTo(modeLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(50)
        }
    }
    
    private func configureTimerCallbacks() {
        pomodoroTimer.onTick = { [weak self] formattedTime in
            self?.timerLabel.text = formattedTime
        }
        
        pomodoroTimer.onModeChange = { [weak self] modeDescription in
            self?.modeLabel.text = modeDescription.contains("Work") ? "Work" : "Break"
        }
        
        pomodoroTimer.onStreakUpdate = { [weak self] currentStreak, overallStreak in
            print("Current Streak: \(currentStreak), Overall Streak: \(overallStreak)")
        }
    }
    
    @objc private func startTimer() {
        pomodoroTimer.start()
    }
    
    @objc private func pauseTimer() {
        pomodoroTimer.pause()
    }
    
    @objc private func stopTimer() {
        pomodoroTimer.stop()
        timerLabel.text = "25:00"
        modeLabel.text = "Work"
    }
}
