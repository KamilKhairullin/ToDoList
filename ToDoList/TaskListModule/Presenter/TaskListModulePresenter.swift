import Foundation

protocol TaskListModuleInput: AnyObject {
    func reloadData()
}

protocol TaskListModuleOutput: AnyObject {
    func showCreateNewTask()
}

final class TaskListModulePresenter {
    // MARK: - Properties

    weak var view: TaskListModuleViewInput?
    let output: TaskListModuleOutput

    private let fileCache: FileCache

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
}

// MARK: - TaskListModuleViewOutput extension

extension TaskListModulePresenter: TaskListModuleViewOutput {
    func plusButtonPressed() {
        output.showCreateNewTask()
    }

    func getCellData(forIndexPath indexPath: IndexPath) -> TaskListTableViewCellData {
        switch indexPath.row {
        case fileCache.todoItems.count:
            return TaskListTableViewCellData.createNewTaskCell
        default:
            let item = fileCache.todoItems[indexPath.row]
            return TaskListTableViewCellData.taskCell(
                TaskCellViewState(
                    text: item.text,
                    hideSubtitle: item.deadline == nil,
                    isDone: item.isDone,
                    isOverdue: false, // TODO
                    deadlineString: item.deadline?.taskListFormat,
                    priorityImageName: priorityToImageName(item.priority)
                )
            )
        }
    }

    func getRowsNumber() -> Int {
        return fileCache.todoItems.count
    }
}

extension TaskListModulePresenter: TaskListModuleInput {
    func reloadData() {
        view?.reloadData()
    }
}
