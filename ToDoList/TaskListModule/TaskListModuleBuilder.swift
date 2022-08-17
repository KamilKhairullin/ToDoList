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

    init(output: TaskListModuleOutput, fileCache: FileCacheService) {
        presenter = TaskListModulePresenter(output: output, fileCache: fileCache)
        viewController = TaskListModuleViewController(output: presenter)
        presenter.view = viewController
    }
}
