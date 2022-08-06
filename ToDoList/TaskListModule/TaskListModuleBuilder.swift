import Foundation

final class TaskListModuleBuilder {
    let viewController: TaskListModuleViewController
    private let presenter: TaskListModulePresenter

    init() {
        presenter = TaskListModulePresenter()
        viewController = TaskListModuleViewController(output: presenter)
        presenter.view = viewController
    }
}
