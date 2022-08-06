import Foundation

protocol TaskListModuleViewInput: AnyObject {}

protocol TaskListModuleViewOutput: AnyObject {}

final class TaskListModulePresenter {
    // MARK: - Properties

    weak var view: TaskListModuleViewInput?
}

// MARK: - TaskListModuleViewOutput extension

extension TaskListModulePresenter: TaskListModuleViewOutput {}
