import Foundation

struct NetworkTodoItem {
    // MARK: - Properties

    let id: String
    let text: String
    let priority: Priority
    let deadline: Date?
    let isDone: Bool
    let createdAt: Date
    let editedAt: Date?

    // MARK: - Lifecycle

    init(
        id: String,
        text: String,
        priority: Priority,
        deadline: Date? = nil,
        isDone: Bool,
        createdAt: Date,
        editedAt: Date? = nil
    ) {
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
        self.isDone = isDone
        self.createdAt = createdAt
        self.editedAt = editedAt
    }
}

// MARK: - Nested types

extension NetworkTodoItem {
    enum Priority: Int, Codable {
        case important
        case ordinary
        case unimportant
    }
}

// MARK: - Codable extension

extension NetworkTodoItem: Decodable {}
