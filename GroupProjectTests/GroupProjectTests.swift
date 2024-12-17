import XCTest
@testable import GroupProject

final class TimerTests: XCTestCase {

    var backgroundTimer: TextTimer!
    var tickedTime: String?
    
    override func setUp() {
        super.setUp()
        backgroundTimer = TextTimer()
        tickedTime = nil
    }
    
    override func tearDown() {
        backgroundTimer = nil
        tickedTime = nil
        super.tearDown()
    }

    func testStartTimer() {
        let expectation = XCTestExpectation(description: "Timer ticks correctly")

        backgroundTimer.onTick = { time in
            self.tickedTime = time
            expectation.fulfill()
        }

        backgroundTimer.start(withInterval: 1.0)

        // wait for 1.5 seconds to ensure the timer works
        wait(for: [expectation], timeout: 1.5)
        
        XCTAssertNotNil(tickedTime)
        XCTAssertEqual(tickedTime, "0:01")
    }
    
    func testPauseTimer() {
        let expectation = XCTestExpectation(description: "Timer pauses correctly")
        
        backgroundTimer.onTick = { time in
            self.tickedTime = time
            self.backgroundTimer.pause()
            expectation.fulfill()
        }
        
        backgroundTimer.start(withInterval: 1.0)

        // wait for 1.5 seconds to simulate pause
        wait(for: [expectation], timeout: 1.5)
        
        XCTAssertEqual(tickedTime, "0:01")
        
        // wait another 1 second to ensure the timer does not continue ticking
        sleep(1)
        XCTAssertEqual(tickedTime, "0:01")
    }
    
    func testResumeTimer() {
        let expectation = XCTestExpectation(description: "Timer resumes correctly")
        let pauseExpectation = XCTestExpectation(description: "Timer pauses")
        
        var pauseTime: String?

        backgroundTimer.onTick = { time in
            if pauseTime == nil {
                pauseTime = time
                self.backgroundTimer.pause()
                pauseExpectation.fulfill()
            } else {
                self.tickedTime = time
                expectation.fulfill()
            }
        }

        // start timer
        backgroundTimer.start(withInterval: 1.0)
        wait(for: [pauseExpectation], timeout: 1.5)

        XCTAssertEqual(pauseTime, "0:01")
        
        // resume timer
        backgroundTimer.start(withInterval: 1.0)
        wait(for: [expectation], timeout: 1.5)

        XCTAssertEqual(tickedTime, "0:02")
    }
}

final class PomodoroTimerTests: XCTestCase {
    var pomodoroTimer: PomodoroTimer!
    var tickedTime: String?
    var modeMessage: String?
    var currentStreak: Int = 0
    var overallStreak: Int = 0
    
    override func setUp() {
        super.setUp()
        pomodoroTimer = PomodoroTimer()
        
        // Bind callbacks
        pomodoroTimer.onTick = { time in
            self.tickedTime = time
        }
        pomodoroTimer.onModeChange = { message in
            self.modeMessage = message
        }
        pomodoroTimer.onStreakUpdate = { current, overall in
            self.currentStreak = current
            self.overallStreak = overall
        }
    }
    
    override func tearDown() {
        pomodoroTimer = nil
        tickedTime = nil
        modeMessage = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(currentStreak, 0)
        XCTAssertEqual(overallStreak, 0)
        XCTAssertNil(tickedTime)
    }

    func testStartWorkSession() {
        let expectation = XCTestExpectation(description: "Work session starts correctly")

        pomodoroTimer.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            XCTAssertEqual(self.modeMessage, "Work Session Started")
            XCTAssertNotNil(self.tickedTime)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testPauseTimer() {
        let expectation = XCTestExpectation(description: "Timer pauses correctly")

        pomodoroTimer.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            self.pomodoroTimer.pause()
            XCTAssertEqual(self.modeMessage, "Timer paused")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testStopTimer() {
        let expectation = XCTestExpectation(description: "Timer stops and resets correctly")

        pomodoroTimer.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            self.pomodoroTimer.stop()
            XCTAssertEqual(self.modeMessage, "Timer stopped. Current streak reset.")
            XCTAssertEqual(self.currentStreak, 0)
            XCTAssertEqual(self.overallStreak, 0)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2.0)
    }

    func testWorkBreakCycle() {
        let expectation = XCTestExpectation(description: "Work/break cycle completes correctly")
        pomodoroTimer.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.pomodoroTimer.exposeFinishCycle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertEqual(self.modeMessage, "Break Session Started")
            XCTAssertEqual(self.currentStreak, 1)
            XCTAssertEqual(self.overallStreak, 1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
    }

    func testConsecutiveWorkBreakCycles() {
        let expectation = XCTestExpectation(description: "Multiple work/break cycles complete correctly")

        pomodoroTimer.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.pomodoroTimer.exposeFinishCycle() // Finish work session
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.pomodoroTimer.exposeFinishCycle() // Finish break session
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.pomodoroTimer.exposeFinishCycle() // Finish work session
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.pomodoroTimer.exposeFinishCycle() // Finish break session
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            XCTAssertEqual(self.currentStreak, 2)
            XCTAssertEqual(self.overallStreak, 2)
            XCTAssertEqual(self.modeMessage, "Work Session Started")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 6.0)
    }
}
