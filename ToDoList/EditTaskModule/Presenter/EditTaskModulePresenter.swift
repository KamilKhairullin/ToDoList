import Foundation

protocol EditTaskModuleViewInput: AnyObject {
    func update(
        text: String,
        prioritySegment: Int,
        switchIsOn: Bool,
        deadlineDate: String
    )

    func update(dateString: String)
    func isCalendarHidden(_ isHidded: Bool, dateString: String, date: Date)
}

protocol EditTaskModuleViewOutput: AnyObject {
    func save(
        text: String,
        prioritySegment: Int,
        switchIsOn: Bool,
        deadlineDate: Date?
    )

    func switchTapped(isOn: Bool)

    func newDatePicked(date: Date)
}

final class EditTaskModulePresenter {
    weak var view: EditTaskModuleViewInput?

    private var todoItem: TodoItem?
    private var fileCache: FileCache

    init(fileCache: FileCache) {
        self.fileCache = fileCache
        loadCacheFromFile()
    }

    private func saveCacheToFile() {
        if let todoItem = todoItem {
            fileCache.addTask(todoItem)
            fileCache.save(to: Constants.filename)
        }
    }

    private func loadCacheFromFile() {
        fileCache.load(from: Constants.filename)
        todoItem = fileCache.todoItems.first

        if let todoItem = todoItem {
            view?.update(
                text: todoItem.text,
                prioritySegment: todoItem.priority.rawValue - 1,
                switchIsOn: todoItem.deadline != nil,
                deadlineDate: formatDate(from: todoItem.deadline)
            )
        }
    }

    private func formatDate(from date: Date?) -> String {
        guard let date = date else {
            return ""
        }
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMMM yyyy"
        return dateFormatterPrint.string(from: date)
    }
}

extension EditTaskModulePresenter: EditTaskModuleViewOutput {
    func newDatePicked(date: Date) {
        view?.update(dateString: formatDate(from: date))
    }

    func switchTapped(isOn: Bool) {
        let tomorrow = Date.tomorrow
        view?.isCalendarHidden(!isOn, dateString: formatDate(from: tomorrow), date: tomorrow)
    }

    func save(text: String, prioritySegment: Int, switchIsOn: Bool, deadlineDate: Date?) {
        let priority: TodoItem.Priority
        let deadline: Date?

        switch prioritySegment {
        case 0:
            priority = .unimportant
        case 2:
            priority = .important
        default:
            priority = .ordinary
        }

        deadline = switchIsOn ? deadlineDate : nil

        if let currentItem = todoItem {
            todoItem = TodoItem(
                id: currentItem.id,
                text: text,
                priority: priority,
                deadline: deadline,
                isDone: false,
                createdAt: currentItem.createdAt,
                editedAt: Date()
            )
        } else {
            todoItem = TodoItem(
                text: text,
                priority: priority,
                deadline: deadline,
                isDone: false,
                createdAt: Date(),
                editedAt: nil
            )
        }
        saveCacheToFile()
    }
}

// MARK: - Nested types

extension EditTaskModulePresenter {
    enum Constants {
        static let filename = "savedCache.json"
    }
}
