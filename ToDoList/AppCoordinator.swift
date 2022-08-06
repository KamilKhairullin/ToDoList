import UIKit

final class AppCoordinator {
    let rootViewController: UIViewController

    init() {
        let builder = TaskListModuleBuilder()
        rootViewController = CustomNavigationController(rootViewController: builder.viewController, title: "Мои дела")
    }
}
