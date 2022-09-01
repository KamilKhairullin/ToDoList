import Foundation
import UIKit

protocol EditTaskModuleInput: AnyObject {}

protocol EditTaskModuleOutput: AnyObject {
    func dismissPresented(on viewController: UIViewController)
}

final class EditTaskModulePresenter {
    // MARK: - Properties

    weak var view: EditTaskModuleViewInput? {
        didSet {
            updateView()
        }
    }

    private var output: EditTaskModuleOutput

    private var todoItem: TodoItem {
        didSet {
            updateView()
        }
    }

    private let serviceCoordinator: ServiceCoordinator
    private var showPlaceholder: Bool

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = .none
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()

    // MARK: - Lifecycle

    init(output: EditTaskModuleOutput, serviceCoordinator: ServiceCoordinator, with todoItem: TodoItem?) {
        self.output = output
        self.serviceCoordinator = serviceCoordinator
        self.showPlaceholder = todoItem != nil ? false : true
        self.todoItem = todoItem ?? EditTaskModulePresenter.makeDefaultItem()
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

    private static func makeDefaultItem() -> TodoItem {
        TodoItem(
            text: Constants.defaultText,
            priority: Constants.defaultPriority,
            deadline: Constants.defaultDeadline,
            isDone: false,
            editedAt: nil
        )
    }

    private func updateView() {
        let hasDeadline = todoItem.deadline != nil
        let saveEnabled = todoItem.text != Constants.emptyText && !showPlaceholder

        view?.update(
            text: todoItem.text,
            showPlaceholder: showPlaceholder,
            prioritySegment: EditTaskModulePresenter.toSegment(todoItem.priority),
            switchIsOn: hasDeadline,
            isCalendarShown: hasDeadline,
            deadline: todoItem.deadline,
            deadlineString: todoItem.deadline?.format(with: dateFormatter),
            isDeleteEnabled: true,
            isSaveEnabled: saveEnabled
        )
    }
}

// MARK: - EditTaskModuleViewOutput extension

extension EditTaskModulePresenter: EditTaskModuleViewOutput {
    func cancelPressed(on viewController: UIViewController) {
        output.dismissPresented(on: viewController)
    }

    func textEdited(to text: String) {
        let text = showPlaceholder ? Constants.emptyText : text
        showPlaceholder = false

        todoItem = TodoItem(
            id: todoItem.id,
            text: text,
            priority: todoItem.priority,
            deadline: todoItem.deadline,
            isDone: todoItem.isDone,
            createdAt: todoItem.createdAt,
            editedAt: Date()
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
            editedAt: Date()
        )
    }

    func deletePressed(on viewController: UIViewController) {
        showPlaceholder = true
        self.serviceCoordinator.removeItem(at: todoItem.id) { _ in }
        output.dismissPresented(on: viewController)
    }

    func newDatePicked(_ date: Date) {
        todoItem = TodoItem(
            id: todoItem.id,
            text: todoItem.text,
            priority: todoItem.priority,
            deadline: date,
            isDone: todoItem.isDone,
            createdAt: todoItem.createdAt,
            editedAt: Date()
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
            editedAt: Date()
        )
    }

    func savePressed(on viewController: UIViewController) {
        let isAlreadyExists = !serviceCoordinator.todoItems.filter { $0.id == todoItem.id }.isEmpty

        let item = TodoItem(
            id: todoItem.id,
            text: todoItem.text,
            priority: todoItem.priority,
            deadline: todoItem.deadline,
            isDone: todoItem.isDone,
            createdAt: todoItem.createdAt,
            editedAt: todoItem.editedAt
        )

        if isAlreadyExists {
            serviceCoordinator.updateItem(item: item) { _ in }
        } else {
            serviceCoordinator.addItem(item: item) { _ in }
        }

        output.dismissPresented(on: viewController)
    }
}

// MARK: - Nested types

extension EditTaskModulePresenter {
    enum Constants {
        static let defaultText: String = "Что будем делать?"
        static let defaultPriority: TodoItem.Priority = .ordinary
        static let defaultDeadline: Date? = nil
        static let emptyText: String = ""
    }
}
