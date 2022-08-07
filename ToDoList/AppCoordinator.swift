import UIKit

final class AppCoordinator {
    var rootViewController: UIViewController = .init()
    let fileCache: FileCache

    var taskListModule: TaskListModuleBuilder?

    init() {
        fileCache = FileCache()
        fileCache.load(from: "savedCache.json")
        taskListModule = taskListModuleBuilder()
        rootViewController = CustomNavigationController(
            rootViewController: taskListModule?.viewController,
            title: "Мои дела"
        )
    }
}

extension AppCoordinator {
    private func taskListModuleBuilder() -> TaskListModuleBuilder {
        return TaskListModuleBuilder(output: self, fileCache: fileCache)
    }
}

// MARK: - EditTaskModuleOutput extension

extension AppCoordinator: EditTaskModuleOutput {
    func dismissPresented() {
        rootViewController.dismiss(animated: true)
        taskListModule?.input.reloadData()
    }
}

// MARK: - TaskListModuleOutput extension

extension AppCoordinator: TaskListModuleOutput {
    func showCreateNewTask() {
        let builder = EditTaskModuleBuilder(output: self, fileCache: fileCache)
        let viewController = builder.viewController
        let viewToPresent = UINavigationController(rootViewController: viewController)
        rootViewController.present(viewToPresent, animated: true)
    }
}
