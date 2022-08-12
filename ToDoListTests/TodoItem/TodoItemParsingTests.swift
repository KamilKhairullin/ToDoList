@testable import ToDoList
import XCTest
import TodoListModels

class TodoItemParsingTests: XCTestCase {
    func test_encodedAndDecoded_Equals() throws {
        let task = TodoItem(
            id: "Abcdefg",
            text: """
                Lorem Ipsum is simply dummy text of the printing and typesetting
                industry. Lorem Ipsum has been the industry's standard dummy text
                ever since the 1500s, when an unknown printer took a galley of type
                and scrambled it to make a type specimen book. It has survived not
                only five centuries, but also the leap into electronic typesetting,
                remaining essentially unchanged. It was popularised in the 1960s with
                the release of Letraset sheets containing Lorem Ipsum passages, and
                more recently with desktop publishing software like Aldus PageMaker
                including versions of Lorem Ipsum.
            """,
            priority: .important,
            deadline: Date().addingTimeInterval(10000),
            isDone: false,
            editedAt: Date().addingTimeInterval(5000)
        )

        let encoded = task.json
        let decodedOptional = TodoItem.parse(json: encoded)
        XCTAssertNotNil(decodedOptional)
        let decoded = decodedOptional!
        XCTAssertEqual(task.id, decoded.id)
        XCTAssertEqual(task.text, decoded.text)
        XCTAssertEqual(task.priority, decoded.priority)
        XCTAssertEqual(task.isDone, decoded.isDone)
    }

    func test_parseUnwrappingFailed_ifInvalidJson() throws {
        let json: Any = [1: true, 2: false]
        XCTAssertNil(TodoItem.parse(json: json))
    }

    func test_deadlineIsNil_ifNotGiven() {
        let item = TodoItem(text: "mock", priority: .important)
        let parsed = TodoItem.parse(json: item.json)
        XCTAssertNil(parsed?.deadline)
    }

    func test_deadlineIsNotNil_ifGiven() {
        let item = TodoItem(text: "mock", priority: .important, deadline: Date())
        let parsed = TodoItem.parse(json: item.json)
        XCTAssertNotNil(parsed?.deadline)
    }

    func test_priorityIsDefault_ifNotGiven() {
        let defaultPriority = TodoItem.Constants.defaultPriority
        let item = TodoItem(text: "mock", priority: defaultPriority)
        let parsed = TodoItem.parse(json: item.json)
        XCTAssertEqual(defaultPriority, parsed?.priority)
    }

    func test_failure_ifPriorityIsOutOfRange() {
        let json: [String: Any] = [
            "id": "DB993596-386F-4C7D-9DAB-752E519D42F6",
            "priority": Int.max,
            "text": "Aboba3",
            "createdAt": 1659148454.8373461,
            "isDone": true
        ]
        XCTAssertNil(TodoItem.parse(json: json))
    }
}
