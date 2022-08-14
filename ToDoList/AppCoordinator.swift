import UIKit
import CocoaLumberjack

final class AppCoordinator {
    var rootViewController: UIViewController = .init()
    let fileCacheService: FileCacheService
    var taskListModule: TaskListModuleBuilder?

    init() {
        self.fileCacheService = MockFileCacheService(fileCache: .init())
        fileCacheService.load(from: Constants.filename) { _ in
            self.taskListModule?.input.reloadData()
        }
        taskListModule = taskListModuleBuilder()
        rootViewController = CustomNavigationController(
            rootViewController: taskListModule?.viewController,
            title: Constants.rootViewControllerTitle
        )
        setupCocoaLumberjack()
    }

    func deleteItem(item: TodoItem) {
        fileCacheService.delete(id: item.id) { _ in }
        fileCacheService.save(to: Constants.filename) { _ in }
    }

    func saveCacheToFile() {
        fileCacheService.save(to: Constants.filename) { _ in }
    }
}

extension AppCoordinator {

    private func setupCocoaLumberjack() {
        DDLog.add(DDOSLogger.sharedInstance)
        let message = Constants.logMessage
        DDLog.log(asynchronous: true, message: message)
    }

    private func taskListModuleBuilder() -> TaskListModuleBuilder {
        return TaskListModuleBuilder(output: self, fileCache: fileCacheService)
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
    func preview(indexPath: IndexPath) -> UIViewController {
        let todoItem = fileCacheService.todoItems[indexPath.row]
        let builder = EditTaskModuleBuilder(output: self, fileCache: fileCacheService, with: todoItem)
        return builder.viewController
    }

    func selectRowAt(indexPath: IndexPath, on viewController: UIViewController) {
        let todoItem = fileCacheService.todoItems[indexPath.row]
        let builder = EditTaskModuleBuilder(output: self, fileCache: fileCacheService, with: todoItem)
        viewController.navigationController?.pushViewController(builder.viewController, animated: true)
    }

    func showCreateNewTask() {
        let builder = EditTaskModuleBuilder(output: self, fileCache: fileCacheService, with: nil)
        let viewController = builder.viewController
        let viewToPresent = UINavigationController(rootViewController: viewController)
        rootViewController.present(viewToPresent, animated: true)
    }
}

// MARK: - Nested types

extension AppCoordinator {
    enum Constants {
        static let filename: String = "savedCache.json"
        static let rootViewControllerTitle = "Мои дела"
        static let logMessage: DDLogMessage = .init(
            message: "App coordinator initialized.",
            level: .all,
            flag: .info,
            context: 1,
            file: "file.txt",
            function: nil,
            line: 0,
            tag: nil,
            options: [],
            timestamp: Date()
        )
    }
}
