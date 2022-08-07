import UIKit

final class AppCoordinator {
    var rootViewController: UIViewController = .init()
    let fileCache: FileCache

    var taskListModule: TaskListModuleBuilder?

    init() {
        fileCache = FileCache()
        fileCache.load(from: "savedCache.json")
        print(fileCache.todoItems)
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
    func dismissPresented(on viewController: UIViewController) {
        viewController.dismiss(animated: true)
        viewController.navigationController?.popViewController(animated: true)
        taskListModule?.input.reloadData()
    }
}

// MARK: - TaskListModuleOutput extension

extension AppCoordinator: TaskListModuleOutput {
    func selectRowAt(indexPath: IndexPath, on viewController: UIViewController) {
        let todoItem = fileCache.todoItems[indexPath.row]
        let builder = EditTaskModuleBuilder(output: self, fileCache: fileCache, with: todoItem)
//        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.navigationController?.pushViewController(builder.viewController, animated: true)
    }

    func showCreateNewTask() {
        let builder = EditTaskModuleBuilder(output: self, fileCache: fileCache, with: nil)
        let viewController = builder.viewController
        let viewToPresent = UINavigationController(rootViewController: viewController)
        rootViewController.present(viewToPresent, animated: true)
    }
}
