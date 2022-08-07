import Foundation

protocol EditTaskModuleInput: AnyObject {
    func loadItemFromCache(id: String)
}

protocol EditTaskModuleOutput: AnyObject {
    func dismissPresented()
}

final class EditTaskModulePresenter {
    // MARK: - Properties

    weak var view: EditTaskModuleViewInput? {
        didSet {
            todoItem = EditTaskModulePresenter.makeDefaultItem()
//            loadCacheFromFile()
        }
    }

    private var output: EditTaskModuleOutput

    private var todoItem: TodoItem {
        didSet {
            let hasDeadline = todoItem.deadline != nil
            let saveEnabled = todoItem.text != Constants.emptyText && !showPlaceholder

            view?.update(
                text: todoItem.text,
                showPlaceholder: showPlaceholder,
                prioritySegment: EditTaskModulePresenter.toSegment(todoItem.priority),
                switchIsOn: hasDeadline,
                isCalendarShown: hasDeadline,
                deadline: todoItem.deadline,
                deadlineString: todoItem.deadline?.editTaskFormat,
                isDeleteEnabled: true,
                isSaveEnabled: saveEnabled
            )
        }
    }

    private let fileCache: FileCache
    private var showPlaceholder = true

    // MARK: - Lifecycle

    init(output: EditTaskModuleOutput, fileCache: FileCache) {
        self.output = output
        self.fileCache = fileCache
        self.todoItem = EditTaskModulePresenter.makeDefaultItem()
    }

    // MARK: - Public

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
            showPlaceholder = false
        } else {
            todoItem = EditTaskModulePresenter.makeDefaultItem()
        }
    }// TODO

    private func saveCacheToFile() {
        fileCache.addTask(todoItem)
        print(fileCache.todoItems)
        fileCache.save(to: Constants.filename)
    }

    private static func makeDefaultItem() -> TodoItem {
        TodoItem(
            text: Constants.defaultText,
            priority: Constants.defaultPriority,
            deadline: Constants.defaultDeadline,
            isDone: false,
            editedAt: nil
        )
    }
}

extension EditTaskModulePresenter: EditTaskModuleViewOutput {
    func cancelPressed() {
        output.dismissPresented()
    }

    func textEdited(to text: String) {
        showPlaceholder = false
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
        showPlaceholder = true
        fileCache.deleteTask(id: todoItem.id)
        fileCache.save(to: Constants.filename)
//        fileCache.deleteCacheFile(file: Constants.filename)
        todoItem = EditTaskModulePresenter.makeDefaultItem()
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
        output.dismissPresented()
    }
}

// MARK: - Nested types

extension EditTaskModulePresenter {
    enum Constants {
        static let filename: String = "savedCache.json"
        static let defaultText: String = "Что будем делать?"
        static let defaultPriority: TodoItem.Priority = .ordinary
        static let defaultDeadline: Date? = nil
        static let emptyText: String = ""
    }
}

extension EditTaskModulePresenter: EditTaskModuleInput {
    func loadItemFromCache(id: String) {
        fileCache.load(from: Constants.filename)
        if let loadedItem = fileCache.todoItems.first {
            todoItem = loadedItem
            showPlaceholder = false
        }
    }
}
