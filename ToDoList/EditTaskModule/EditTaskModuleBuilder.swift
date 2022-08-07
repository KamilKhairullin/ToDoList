import Foundation

final class EditTaskModuleBuilder {
    let viewController: EditTaskModuleViewController
    private let presenter: EditTaskModulePresenter

    init(output: EditTaskModuleOutput, fileCache: FileCache) {
        presenter = EditTaskModulePresenter(output: output, fileCache: fileCache)
        viewController = EditTaskModuleViewController(output: presenter)
        presenter.view = viewController
    }
}
