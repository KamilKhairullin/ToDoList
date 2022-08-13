import Foundation
import UIKit
import TodoListModels

protocol TaskListModuleInput: AnyObject {
    func reloadData()
}

protocol TaskListModuleOutput: AnyObject {
    func showCreateNewTask()
    func selectRowAt(indexPath: IndexPath, on viewController: UIViewController)
    func deleteItem(item: TodoItem)
    func preview(indexPath: IndexPath) -> UIViewController
}

final class TaskListModulePresenter {
    // MARK: - Properties

    weak var view: TaskListModuleViewInput? {
        didSet {
            reloadData()
        }
    }
    let output: TaskListModuleOutput

    private let fileCache: FileCache
    private var doneIsHidden = false
    private var todoItems: [TodoItem] {
        if doneIsHidden {
            return fileCache.todoItems.filter { !$0.isDone }
        }
        return fileCache.todoItems
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = .none
        formatter.dateFormat = "dd MMMM"
        return formatter
    }()

    // MARK: - Lifecycle

    init(output: TaskListModuleOutput, fileCache: FileCache) {
        self.output = output
        self.fileCache = fileCache
    }

    // MARK: - Private

    private func priorityToImageName(_ priority: TodoItem.Priority) -> String? {
        switch priority {
        case .important:
            return "highPriority"
        case .unimportant:
            return "lowPriority"
        case .ordinary:
            return nil
        }
    }

    private func calculateNumberOfLinesForText(item: TodoItem, lineWidth: Int) -> Int {
        let fontAttributes = [NSAttributedString.Key.font: FontPalette.body]
        let size = Int((item.text as NSString).size(withAttributes: fontAttributes).width)

        return min(Constants.maxNumberOfLines, (size / lineWidth) + 1)
    }

    private func isOverdue(deadline: Date?) -> Bool {
        guard let deadline = deadline else {
            return false
        }
        return Date() > deadline
    }
}

// MARK: - TaskListModuleViewOutput extension

extension TaskListModulePresenter: TaskListModuleViewOutput {
    func preview(indexPath: IndexPath) -> UIViewController {
        return output.preview(indexPath: indexPath)
    }

    func hideDoneButtonState() -> Bool {
        doneIsHidden
    }

    func numberOfDoneItems() -> Int {
        fileCache.todoItems.filter { $0.isDone }.count
    }

    func lastRowIndex() -> Int {
        todoItems.count
    }

    func hideDonePressed() {
        doneIsHidden = !doneIsHidden
        view?.reloadData()
    }

    func deleteSwipe(indexPath: IndexPath) {
        let item = todoItems[indexPath.row]
        output.deleteItem(item: item)
        view?.reloadData()
    }

    func completeButtonPressed(indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            return
        }
        let item = todoItems[indexPath.row]
        fileCache.addTask(TodoItem(
            id: item.id,
            text: item.text,
            priority: item.priority,
            deadline: item.deadline,
            isDone: !item.isDone,
            createdAt: item.createdAt,
            editedAt: Date()
        )
        )
        view?.reloadData()
    }

    func selectRowAt(indexPath: IndexPath, on viewController: UIViewController) {
        if indexPath.row == todoItems.count {
            output.showCreateNewTask()
        } else {
            output.selectRowAt(indexPath: indexPath, on: viewController)
        }
    }

    func plusButtonPressed() {
        output.showCreateNewTask()
    }

    func cellData(_ indexPath: IndexPath) -> TaskListTableViewCellData {
        switch indexPath.row {
        case todoItems.count:
            return TaskListTableViewCellData.createNewTaskCell
        default:
            let item = todoItems[indexPath.row]

            return TaskListTableViewCellData.taskCell(
                TaskCellViewState(
                    text: item.text,
                    hideSubtitle: item.deadline == nil,
                    isDone: item.isDone,
                    isOverdue: isOverdue(deadline: item.deadline),
                    deadlineString: item.deadline?.format(with: dateFormatter),
                    priorityImageName: priorityToImageName(item.priority),
                    output: self
                )
            )
        }
    }

    func rowsNumber() -> Int {
        return todoItems.count + 1
    }

    func rowHeight(forIndexPath indexPath: IndexPath, lineWidth: Int) -> Int {
        switch indexPath.row {
        case todoItems.count:
            return Constants.defaultCellHeight
        default:
            let item = todoItems[indexPath.row]
            var rowHeight = Constants.defaultCellHeight
            if item.deadline != nil {
                rowHeight += Constants.subtitleHeight
            }
            let numberOfTextLines = calculateNumberOfLinesForText(item: item, lineWidth: lineWidth)
            for _ in 1 ..< numberOfTextLines {
                rowHeight += Constants.textRowHeight
            }
            return rowHeight
        }
    }
}

// MARK: - Nested types

extension TaskListModulePresenter {
    enum Constants {
        static let defaultCellHeight = 56
        static let subtitleHeight = 10
        static let textRowHeight = 22
        static let maxNumberOfLines = 3
    }
}

// MARK: - TaskListModuleInput extension

extension TaskListModulePresenter: TaskListModuleInput {
    func reloadData() {
        view?.reloadData()
    }
}
