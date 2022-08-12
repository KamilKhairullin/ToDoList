@testable import ToDoList
import XCTest
import TodoListModels

class TodoItemTests: XCTestCase {

    func test_shouldGenerateId_ifNotGiven() throws {
        let task = TodoItem(text: "mock", priority: .unimportant)
        XCTAssert(!task.text.isEmpty)
    }

    func test_id_ifGiven() throws {
        let id = UUID().uuidString
        let task = TodoItem(id: id, text: "mock", priority: .important)
        XCTAssertEqual(id, task.id)
    }

    func test_deadlineIsNil_ifNotGiven() throws {
        let task = TodoItem(text: "mock", priority: .unimportant)
        XCTAssertNil(task.deadline)
    }

    func test_deadlineIsNotNil_ifGiven() throws {
        let date = Date()
        let task = TodoItem(text: "mock", priority: .unimportant, deadline: date)
        XCTAssertEqual(date, task.deadline!)
    }

    func test_creationDate_ifNotGiven() throws {
        let dateBefore = Date()
        let task = TodoItem(text: "mock", priority: .unimportant)
        let dateAfter = Date()
        XCTAssertLessThanOrEqual(dateBefore, task.createdAt)
        XCTAssertLessThanOrEqual(task.createdAt, dateAfter)
    }

    func test_isDone_ifNotGiven() throws {
        let task = TodoItem(text: "mock", priority: .unimportant)
        XCTAssertFalse(task.isDone)
    }

    func test_isDone_ifGiven() throws {
        let task = TodoItem(text: "mock", priority: .unimportant, isDone: true)
        XCTAssertTrue(task.isDone)
    }
}
