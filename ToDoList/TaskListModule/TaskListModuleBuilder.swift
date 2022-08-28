import Foundation

final class TaskListModuleBuilder {
    let viewController: TaskListModuleViewController
    private let presenter: TaskListModulePresenter

    var output: TaskListModuleOutput {
        presenter.output
    }

    var input: TaskListModuleInput {
        presenter
    }

    init(output: TaskListModuleOutput, serviceCoordinator: ServiceCoordinator) {
        presenter = TaskListModulePresenter(output: output, serviceCoordinator: serviceCoordinator)
        viewController = TaskListModuleViewController(output: presenter)
        presenter.view = viewController
    }
}
