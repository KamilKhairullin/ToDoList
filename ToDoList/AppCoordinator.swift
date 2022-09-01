import UIKit
import CocoaLumberjack

final class AppCoordinator {
    var rootViewController: UIViewController = .init()
    var serviceCoordinator: ServiceCoordinator?
    var taskListModule: TaskListModuleBuilder?

    init() {
        self.serviceCoordinator = ServiceCoordinatorImp(
            networkService: NetworkServiceImp(
                networkClient: NetworkClientImp(urlSession: .init(configuration: .default))
            ),
            fileCacheService: FileCacheServiceImp(fileCache: .init()),
            output: self
        )

        taskListModule = taskListModuleBuilder()
        rootViewController = CustomNavigationController(
            rootViewController: taskListModule?.viewController,
            title: Constants.rootViewControllerTitle
        )
        setupCocoaLumberjack()
    }
}

extension AppCoordinator {

    private func setupCocoaLumberjack() {
        DDLog.add(DDOSLogger.sharedInstance)
        let message = Constants.logMessage
        DDLog.log(asynchronous: true, message: message)
    }

    private func taskListModuleBuilder() -> TaskListModuleBuilder {
        guard let serviceCoordinator = serviceCoordinator else {
            fatalError()
        }
        return TaskListModuleBuilder(output: self, serviceCoordinator: serviceCoordinator)
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
        guard let serviceCoordinator = serviceCoordinator else {
            fatalError()
        }

        let todoItem = serviceCoordinator.todoItems[indexPath.row]
        let builder = EditTaskModuleBuilder(output: self, serviceCoordinator: serviceCoordinator, with: todoItem)
        return builder.viewController
    }

    func selectRowAt(indexPath: IndexPath, on viewController: UIViewController) {
        guard let serviceCoordinator = serviceCoordinator else {
            fatalError()
        }
        let todoItem = serviceCoordinator.todoItems[indexPath.row]
        let builder = EditTaskModuleBuilder(output: self, serviceCoordinator: serviceCoordinator, with: todoItem)
        viewController.navigationController?.pushViewController(builder.viewController, animated: true)
    }

    func showCreateNewTask() {
        guard let serviceCoordinator = serviceCoordinator else {
            fatalError()
        }
        let builder = EditTaskModuleBuilder(output: self, serviceCoordinator: serviceCoordinator, with: nil)
        let viewController = builder.viewController
        let viewToPresent = UINavigationController(rootViewController: viewController)
        rootViewController.present(viewToPresent, animated: true)
    }
}

extension AppCoordinator: ServiceCoordinatorOutput {
    func loadingStarted() {
        self.taskListModule?.input.startAnimatingActivityIndicator()
    }

    func loadingEnded() {
        self.taskListModule?.input.stopAnimatingActivityIndicator()
    }

    func reloadData() {
        self.taskListModule?.input.reloadData()
    }
}
// MARK: - Nested types

extension AppCoordinator {
    enum Constants {
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
