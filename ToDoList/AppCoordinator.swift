import UIKit

final class AppCoordinator {
    var rootViewController: UIViewController = .init()
    let fileCache: FileCache

    var taskListModule: TaskListModuleBuilder?

    init() {
        fileCache = FileCache()
        fileCache.load(from: Constants.filename)
        taskListModule = taskListModuleBuilder()
        rootViewController = CustomNavigationController(
            rootViewController: taskListModule?.viewController,
            title: "Мои дела"
        )
    }

    func deleteItem(item: TodoItem) {
        fileCache.deleteTask(id: item.id)
        fileCache.save(to: Constants.filename)
    }

    func saveFileCache() {
        fileCache.save(to: Constants.filename)
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
    func getPreview(indexPath: IndexPath) -> UIViewController {
        let todoItem = fileCache.todoItems[indexPath.row]
        let builder = EditTaskModuleBuilder(output: self, fileCache: fileCache, with: todoItem)
        return builder.viewController
    }

    func selectRowAt(indexPath: IndexPath, on viewController: UIViewController) {
        let todoItem = fileCache.todoItems[indexPath.row]
        let builder = EditTaskModuleBuilder(output: self, fileCache: fileCache, with: todoItem)
        viewController.navigationController?.pushViewController(builder.viewController, animated: true)
    }

    func showCreateNewTask() {
        let builder = EditTaskModuleBuilder(output: self, fileCache: fileCache, with: nil)
        let viewController = builder.viewController
        let viewToPresent = UINavigationController(rootViewController: viewController)
        rootViewController.present(viewToPresent, animated: true)
    }
}

// MARK: - Nested types

extension AppCoordinator {
    enum Constants {
        static let filename: String = "savedCache.json"
    }
}
