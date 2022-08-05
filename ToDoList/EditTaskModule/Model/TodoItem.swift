import Foundation

protocol JSONParsable {
    static func parse(json: Any) -> TodoItem?
    var json: Any { get }
}

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
        isDone: Bool = false,
        createdAt: Date = Date(),
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

// MARK: - JSONParsable extension

extension TodoItem: JSONParsable {
    var json: Any {
        var dictionary: [String: Any] = [:]

        dictionary[CodingKeys.idKey] = id
        dictionary[CodingKeys.textKey] = text
        dictionary[CodingKeys.isDoneKey] = isDone
        dictionary[CodingKeys.createdAtKey] = createdAt.timeIntervalSince1970

        switch priority {
        case .important, .unimportant:
            dictionary[CodingKeys.priorityKey] = priority.rawValue
        default:
            break
        }

        if let deadline = deadline {
            dictionary[CodingKeys.deadlineKey] = deadline.timeIntervalSince1970
        }

        if let editedAt = editedAt {
            dictionary[CodingKeys.editedAtKey] = editedAt.timeIntervalSince1970
        }

        return dictionary
    }

    static func parse(json: Any) -> TodoItem? {
        guard
            let dict = json as? [String: Any],
            let id = dict[CodingKeys.idKey] as? String,
            let text = dict[CodingKeys.textKey] as? String,
            let isDone = dict[CodingKeys.isDoneKey] as? Bool,
            let createdAtDouble = dict[CodingKeys.createdAtKey] as? Double
        else {
            print("Error during unwrapping json or obligatory properties")
            return nil
        }

        let createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtDouble))
        let priority: Priority
        let deadline: Date?
        let editedAt: Date?

        deadline = (dict[CodingKeys.deadlineKey] as? Double).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
        }

        editedAt = (dict[CodingKeys.editedAtKey] as? Double).flatMap {
            Date(timeIntervalSince1970: TimeInterval($0))
        }

        if let rawValuePriority = dict[CodingKeys.priorityKey] as? Int {
            if let unwrappedPriority = Priority(rawValue: rawValuePriority) {
                priority = unwrappedPriority
            } else {
                print("Error during unwrapping , invalid priority value: \(rawValuePriority) in json")
                return nil
            }
        } else {
            priority = Constants.defaultPriority
        }

        return TodoItem(
            id: id,
            text: text,
            priority: priority,
            deadline: deadline,
            isDone: isDone,
            createdAt: createdAt,
            editedAt: editedAt
        )
    }
}

// MARK: - Nested types

extension TodoItem {
    enum Constants {
        static let defaultPriority: Priority = .ordinary
    }

    enum CodingKeys {
        static let idKey: String = "id"
        static let textKey: String = "text"
        static let isDoneKey: String = "isDone"
        static let priorityKey: String = "priority"
        static let deadlineKey: String = "deadline"
        static let createdAtKey: String = "createdAt"
        static let editedAtKey: String = "editedAt"
    }

    enum Priority: Int {
        case important
        case ordinary
        case unimportant
    }
}
