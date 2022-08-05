import Foundation

protocol EditTaskModuleViewInput: AnyObject {
    // swiftlint:disable:next function_parameter_count
    func update(
        text: String,
        prioritySegment: Int,
        switchIsOn: Bool,
        isCalendarShown: Bool,
        deadline: Date?,
        deadlineString: String?,
        isDeleteEnabled: Bool,
        isSaveEnabled: Bool
    )
}

protocol EditTaskModuleViewOutput: AnyObject {
    func switchTapped(isOn: Bool)

    func newDatePicked(_ date: Date)

    func textEdited(to text: String)

    func prioritySet(to segment: Int)

    func deletePressed()

    func savePressed()
}

final class EditTaskModulePresenter {
    // MARK: - Properties

    weak var view: EditTaskModuleViewInput? {
        didSet {
            loadCacheFromFile()
        }
    }

    private var todoItem: TodoItem {
        didSet {
            let hasDeadline = todoItem.deadline != nil
            let isTextEmpty = todoItem.text == ""
            view?.update(
                text: todoItem.text,
                prioritySegment: EditTaskModulePresenter.toSegment(todoItem.priority),
                switchIsOn: hasDeadline,
                isCalendarShown: hasDeadline,
                deadline: todoItem.deadline,
                deadlineString: EditTaskModulePresenter.formatDate(todoItem.deadline),
                isDeleteEnabled: true,
                isSaveEnabled: !isTextEmpty
            )
        }
    }

    private let fileCache: FileCache

    // MARK: - Lifecycle

    init(fileCache: FileCache) {
        self.fileCache = fileCache
        self.todoItem = Constants.defaultItem
    }

    // MARK: - Public

    static func formatDate(_ date: Date?) -> String {
        guard let date = date else {
            return ""
        }
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMMM yyyy"
        return dateFormatterPrint.string(from: date)
    }

    static func toPriority(_ segment: Int) -> TodoItem.Priority {
        switch segment {
        case 0:
            return .unimportant
        case 2:
            return .important
        default:
            return .ordinary
        }
    }

    static func toSegment(_ priority: TodoItem.Priority) -> Int {
        switch priority {
        case .unimportant:
            return 0
        case .ordinary:
            return 1
        case .important:
            return 2
        }
    }

    // MARK: - Private

    private func loadCacheFromFile() {
        fileCache.load(from: Constants.filename)
        if let loadedItem = fileCache.todoItems.first {
            todoItem = loadedItem
        } else {
            todoItem = Constants.defaultItem
        }
    }

    private func saveCacheToFile() {
        fileCache.addTask(todoItem)
        fileCache.save(to: Constants.filename)
    }
}

extension EditTaskModulePresenter: EditTaskModuleViewOutput {
    func textEdited(to text: String) {
        todoItem = TodoItem(
            id: todoItem.id,
            text: text,
            priority: todoItem.priority,
            deadline: todoItem.deadline,
            isDone: todoItem.isDone,
            createdAt: todoItem.createdAt,
            editedAt: todoItem.editedAt
        )
    }

    func prioritySet(to segment: Int) {
        let priority = EditTaskModulePresenter.toPriority(segment)
        todoItem = TodoItem(
            id: todoItem.id,
            text: todoItem.text,
            priority: priority,
            deadline: todoItem.deadline,
            isDone: todoItem.isDone,
            createdAt: todoItem.createdAt,
            editedAt: todoItem.editedAt
        )
    }

    func deletePressed() {
        _ = fileCache.deleteTask(id: todoItem.id)
        fileCache.deleteCacheFile(file: Constants.filename)
        todoItem = Constants.defaultItem
    }

    func newDatePicked(_ date: Date) {
        todoItem = TodoItem(
            id: todoItem.id,
            text: todoItem.text,
            priority: todoItem.priority,
            deadline: date,
            isDone: todoItem.isDone,
            createdAt: todoItem.createdAt,
            editedAt: todoItem.editedAt
        )
    }

    func switchTapped(isOn: Bool) {
        let deadline = isOn ? Date.tomorrow : nil
        todoItem = TodoItem(
            id: todoItem.id,
            text: todoItem.text,
            priority: todoItem.priority,
            deadline: deadline,
            isDone: todoItem.isDone,
            createdAt: todoItem.createdAt,
            editedAt: todoItem.editedAt
        )
    }

    func savePressed() {
        saveCacheToFile()
    }
}

// MARK: - Nested types

extension EditTaskModulePresenter {
    enum Constants {
        static let filename: String = "savedCache.json"
        static let defaultText: String = "Что будем делать?"
        static let defaultPriority: TodoItem.Priority = .ordinary
        static let defaultDeadline: Date? = nil
        static let defaultItem: TodoItem = .init(
            text: Constants.defaultText,
            priority: Constants.defaultPriority,
            deadline: Constants.defaultDeadline,
            isDone: false,
            editedAt: nil
        )
    }
}
