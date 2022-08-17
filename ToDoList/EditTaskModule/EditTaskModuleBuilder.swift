import Foundation

final class EditTaskModuleBuilder {
    let viewController: EditTaskModuleViewController
    private let presenter: EditTaskModulePresenter

    init(output: EditTaskModuleOutput, fileCache: FileCacheService, with todoItem: TodoItem?) {
        presenter = EditTaskModulePresenter(output: output, fileCache: fileCache, with: todoItem)
        viewController = EditTaskModuleViewController(output: presenter)
        presenter.view = viewController
    }
}
