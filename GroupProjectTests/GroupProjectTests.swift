import XCTest
@testable import GroupProject

final class GroupProjectTests: XCTestCase {

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
