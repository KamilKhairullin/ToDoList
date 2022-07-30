import Foundation

struct TodoItem {
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
        id: String = UUID().uuidString,
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

extension TodoItem {
    enum Priority: String {
        case important
        case ordinary
        case unimportant
    }
}
