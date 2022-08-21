import Foundation
import UIKit

struct NetworkTodoItem {
    // MARK: - Properties

    let id: String
    let text: String
    let priority: Priority
    let deadline: Date?
    let isDone: Bool
    let color: String?
    let createdAt: Date
    let editedAt: Date?
    let lastUpdatedBy: String

    // MARK: - Lifecycle

    init(
        id: String,
        text: String,
        priority: Priority,
        deadline: Date?,
        isDone: Bool,
        color: String?,
        createdAt: Date,
        editedAt: Date?,
        lastUpdatedBy: String
    ) {
        self.id = id
        self.text = text
        self.priority = priority
        self.deadline = deadline
        self.isDone = isDone
        self.color = color
        self.createdAt = createdAt
        self.editedAt = editedAt
        self.lastUpdatedBy = lastUpdatedBy
    }
}

// MARK: - Nested types

extension NetworkTodoItem {
    enum Priority: String, Codable {
        case important = "low"
        case ordinary = "basic"
        case unimportant = "important"

        init(from priority: TodoItem.Priority) {
            switch priority {
            case .unimportant:
                self = .unimportant
            case .ordinary:
                self = .ordinary
            case .important:
                self = .important
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case text = "text"
        case priority = "importance"
        case deadline = "deadline"
        case isDone = "done"
        case color = "color"
        case createdAt = "created_at"
        case editedAt = "changed_at"
        case lastUpdatedBy = "last_updated_by"
    }

    enum Constants {
        static let color: String = ""
        static let defaultDeviceId: String = ""
    }
}

extension NetworkTodoItem {
    init(from todoItem: TodoItem) {
        self.init(
            id: todoItem.id,
            text: todoItem.text,
            priority: Priority(from: todoItem.priority),
            deadline: todoItem.deadline,
            isDone: todoItem.isDone,
            color: Constants.color,
            createdAt: todoItem.createdAt,
            editedAt: todoItem.editedAt ?? Date(),
            lastUpdatedBy: UIDevice.current.identifierForVendor?.uuidString ?? Constants.defaultDeviceId
        )
    }
}

// MARK: - Codable extension

extension NetworkTodoItem: Codable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(priority, forKey: .priority)
        try container.encode(deadline?.noon, forKey: .deadline)
        try container.encode(isDone, forKey: .isDone)
        try container.encode(color, forKey: .color)
        try container.encode(createdAt.noon, forKey: .createdAt)
        try container.encode(editedAt?.noon, forKey: .editedAt)
        try container.encode(lastUpdatedBy, forKey: .lastUpdatedBy)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        text = try values.decode(String.self, forKey: .text)
        priority = try values.decode(Priority.self, forKey: .priority)
        deadline = try? values.decode(Date.self, forKey: .deadline)
        isDone = try values.decode(Bool.self, forKey: .isDone)
        color = try? values.decode(String.self, forKey: .color)
        createdAt = try values.decode(Date.self, forKey: .createdAt)
        editedAt = try? values.decode(Date.self, forKey: .editedAt)
        lastUpdatedBy = try values.decode(String.self, forKey: .lastUpdatedBy)
    }
}
