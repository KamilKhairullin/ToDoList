import Foundation

enum TaskListTableViewCellData {
    case taskCell(TaskCellViewState)
    case createNewTaskCell
}

extension TaskListTableViewCellData {
    var reuseIdentifier: String {
        switch self {
        case .createNewTaskCell:
            return TaskListCreateNewTaskCell.reuseIdentifier
        case .taskCell:
            return TaskListModuleTaskCell.reuseIdentifier
        }
    }
}
