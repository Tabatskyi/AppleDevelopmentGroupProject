import UIKit
import SnapKit
import Combine

class TimerViewController: UIViewController {
    private let timerLabel = UILabel()
    private let startButton = UIButton(type: .system)
    private let pauseButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    private let modeLabel = UILabel()

    private let timerViewModel = TimerViewModel(timer: PomodoroTimer())
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
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

        setupButtons()
    }

    private func setupButtons() {
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = .systemGreen
        startButton.layer.cornerRadius = 8
        startButton.addTarget(self, action: #selector(startTimer), for: .touchUpInside)

        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.setTitleColor(.white, for: .normal)
        pauseButton.backgroundColor = .systemOrange
        pauseButton.layer.cornerRadius = 8
        pauseButton.addTarget(self, action: #selector(pauseTimer), for: .touchUpInside)

        stopButton.setTitle("Stop", for: .normal)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.backgroundColor = .systemRed
        stopButton.layer.cornerRadius = 8
        stopButton.addTarget(self, action: #selector(stopTimer), for: .touchUpInside)

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

    private func bindViewModel() {
        timerViewModel.$timerDisplay
            .sink { [weak self] display in
                self?.timerLabel.text = display
            }
            .store(in: &cancellables)

        timerViewModel.$currentMode
            .sink { [weak self] mode in
                self?.modeLabel.text = mode == .work ? "Work" : "Break"
            }
            .store(in: &cancellables)
    }
    @objc private func startTimer() {
        timerViewModel.start()
    }
    @objc private func pauseTimer() {
        timerViewModel.pause()
    }
    @objc private func stopTimer() {
        timerViewModel.stop()
        modeLabel.text = "Work"
    }
}
