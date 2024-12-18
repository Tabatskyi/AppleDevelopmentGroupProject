import XCTest
@testable import GroupProject

class MainDisplayViewModelTests: XCTestCase {
    
    var testView: viewModel!

    override func setUp() {
        super.setUp()
        
        if let domain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
        UserDefaults.standard.synchronize()

        testView = viewModel()
    }


    override func tearDown() {
        testView = nil
        super.tearDown()
    }

    func testAddTask() {
        XCTAssertEqual(testView.tasks.count, 0, "There were not 0 tasks initially")
        
        testView.addTask(title: "Test", priority: .high)
        
        XCTAssertEqual(testView.tasks.count, 1)
        XCTAssertEqual(testView.tasks.first?.title, "Test")
        XCTAssertEqual(testView.tasks.first?.priority, .high)
        XCTAssertFalse(testView.tasks.first!.isCompleted)
    }
    
    func testCompleteTask() {
        testView.addTask(title: "Test", priority: .medium)
        
        testView.isComplete(at: 0)
        
        XCTAssertTrue(testView.tasks.first!.isCompleted)
        
        testView.isComplete(at: 0)
        XCTAssertFalse(testView.tasks.first!.isCompleted)
    }

    func testDeleteTask() {
        testView.addTask(title: "Test", priority: .low)
        XCTAssertEqual(testView.tasks.count, 1)
        
        testView.deleteTask(at: 0)
        
        XCTAssertEqual(testView.tasks.count, 0)
    }

    func testEditTask() {
        testView.addTask(title: "Test", priority: .low)
        
        testView.editTask(at: 0, newTitle: "Edited test", newPriority: .high)
        
        XCTAssertEqual(testView.tasks.first?.title, "Edited test")
        XCTAssertEqual(testView.tasks.first?.priority, .high)
    }
}
