import Foundation

protocol EditTaskModuleViewInput: AnyObject {
    func update(
        text: String,
        prioritySegment: Int,
        switchIsOn: Bool,
        deadlineDate: String?
    )

    func update(dateString: String)

    func hideCalendar()
    func showCalendar(dateString: String, date: Date)

    func enableDelete()
    func disableDelete()

    func enableSave()
    func disableSave()
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

    func textEdited(to text: String)

    func prioritySelected()

    func deletePressed()
}

final class EditTaskModulePresenter {
    // MARK: - Properties

    weak var view: EditTaskModuleViewInput? {
        didSet {
            loadCacheFromFile()
        }
    }

    private var todoItem: TodoItem? {
        didSet {
            if let todoItem = todoItem {
                view?.update(
                    text: todoItem.text,
                    prioritySegment: toSegment(fromPriority: todoItem.priority),
                    switchIsOn: todoItem.deadline != nil,
                    deadlineDate: formatDate(from: todoItem.deadline)
                )
            } else {
                view?.update(
                    text: Constants.defaultText,
                    prioritySegment: Constants.defaultPrioritySegmentId,
                    switchIsOn: Constants.defaultSwitchStatus,
                    deadlineDate: Constants.defaultDeadline
                )
            }
        }
    }

    private var fileCache: FileCache

    private var isTextEdited: Bool {
        didSet {
            checkIfUpdateButtonsStatus()
        }
    }

    private var isPrioritySelected: Bool {
        didSet {
            checkIfUpdateButtonsStatus()
        }
    }

    private var isDateSelected: Bool {
        didSet {
            checkIfUpdateButtonsStatus()
        }
    }

    // MARK: - Lifecycle

    init(fileCache: FileCache) {
        self.fileCache = fileCache
        isTextEdited = false
        isDateSelected = false
        isPrioritySelected = false
    }

    // MARK: - Private

    private func saveCacheToFile() {
        if let todoItem = todoItem {
            fileCache.addTask(todoItem)
            fileCache.save(to: Constants.filename)
        }
    }

    private func loadCacheFromFile() {
        fileCache.load(from: Constants.filename)
        todoItem = fileCache.todoItems.first
    }

    private func formatDate(from date: Date?) -> String {
        guard let date = date else {
            return ""
        }
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMMM yyyy"
        return dateFormatterPrint.string(from: date)
    }

    private func toPriority(fromSegment segment: Int) -> TodoItem.Priority? {
        switch segment {
        case 0:
            return .unimportant
        case 1:
            return .ordinary
        case 2:
            return .important
        default:
            return nil
        }
    }

    private func toSegment(fromPriority priority: TodoItem.Priority) -> Int {
        switch priority {
        case .unimportant:
            return 0
        case .ordinary:
            return 1
        case .important:
            return 2
        }
    }

    private func checkIfUpdateButtonsStatus() {
        if isPrioritySelected || isTextEdited || isDateSelected {
            view?.enableDelete()
        } else {
            view?.disableDelete()
        }
        if isPrioritySelected, isTextEdited {
            view?.enableSave()
        } else {
            view?.disableSave()
        }
    }
}

extension EditTaskModulePresenter: EditTaskModuleViewOutput {
    func textEdited(to text: String) {
        if text == Constants.defaultText {
            isTextEdited = false
        } else {
            isTextEdited = true
        }
    }

    func prioritySelected() {
        isPrioritySelected = true
    }

    func deletePressed() {
        if let todoItem = todoItem {
            _ = fileCache.deleteTask(id: todoItem.id)
            fileCache.deleteCacheFile(file: Constants.filename)
        }
        view?.hideCalendar()
        todoItem = nil
        isTextEdited = false
        isDateSelected = false
        isPrioritySelected = false
    }

    func newDatePicked(date: Date) {
        isDateSelected = true
        view?.update(dateString: formatDate(from: date))
    }

    func switchTapped(isOn: Bool) {
        if isOn {
            let tomorrow = Date.tomorrow
            view?.showCalendar(dateString: formatDate(from: tomorrow), date: tomorrow)
        } else {
            isDateSelected = false
            view?.hideCalendar()
        }
    }

    func save(text: String, prioritySegment: Int, switchIsOn: Bool, deadlineDate: Date?) {
        guard let priority: TodoItem.Priority = toPriority(fromSegment: prioritySegment)
        else { return }
        let deadline: Date?

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
        static let filename: String = "savedCache.json"
        static let defaultText: String = "Что будем делать?"
        static let defaultPrioritySegmentId: Int = -1
        static let defaultSwitchStatus: Bool = false
        static let defaultDeadline: String? = nil
    }
}
