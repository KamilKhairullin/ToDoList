import Foundation

final class EditTaskModuleBuilder {
    let viewController: EditTaskModuleViewController
    private let presenter: EditTaskModulePresenter

    init(output: EditTaskModuleOutput, serviceCoordinator: ServiceCoordinator, with todoItem: TodoItem?) {
        presenter = EditTaskModulePresenter(output: output, serviceCoordinator: serviceCoordinator, with: todoItem)
        viewController = EditTaskModuleViewController(output: presenter)
        presenter.view = viewController
    }
}
