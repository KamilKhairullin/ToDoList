import Foundation

final class EditTaskModuleBuilder {
    let viewController: EditTaskModuleViewController
    private let presenter: EditTaskModulePresenter

    init(fileCache: FileCache) {
        presenter = EditTaskModulePresenter(fileCache: fileCache)
        viewController = EditTaskModuleViewController(output: presenter)
        presenter.view = viewController
    }
}
