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

    private func calculateNumberOfLinesForText(item: TodoItem, lineWidth: Int) -> Int {
        let fontAttributes = [NSAttributedString.Key.font: FontPalette.body]
        let size = Int((item.text as NSString).size(withAttributes: fontAttributes).width)

        return min(Constants.maxNumberOfLines, (size / lineWidth) + 1)
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
                    isOverdue: false, // TODO:
                    deadlineString: item.deadline?.taskListFormat,
                    priorityImageName: priorityToImageName(item.priority)
                )
            )
        }
    }

    func getRowsNumber() -> Int {
        return fileCache.todoItems.count + 1
    }

    func getRowHeight(forIndexPath indexPath: IndexPath, lineWidth: Int) -> Int {
        switch indexPath.row {
        case fileCache.todoItems.count:
            return Constants.defaultCellHeight
        default:
            let item = fileCache.todoItems[indexPath.row]
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
