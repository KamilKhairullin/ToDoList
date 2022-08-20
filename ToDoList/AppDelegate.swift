import UIKit
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = window else { return false }
        let appCoordinator = AppCoordinator()

        let client = NetworkClientImp(urlSession: .init(configuration: .default))
        let service = NetworkServiceImp(networkClient: client)
        var revision = 1
        service.getAllTodoItems(revision: revision) { result in
            switch result {
            case .success(let data):
                print(data)
                revision = Int(data.revision ?? 0)
            case .failure(let error):
                print(error)
            }
        }

        service.deleteTodoItem(revision: revision, at: "C3ADF355-C80C-4F45-B4B1-2DE210EC30C0") { result in
            switch result {
            case .success(let data):
                print(data.element)
            case .failure(let error):
                print(error)
            }
        }
        
        service.getAllTodoItems(revision: revision) { result in
            switch result {
            case .success(let data):
                print(data)
                revision = Int(data.revision ?? 0)
            case .failure(let error):
                print(error)
            }
        }
//        let todoItem = TodoItem(
//            text: "1",
//            priority: .important,
//            deadline: Date().dayAfter,
//            createdAt: Date().noon,
//            editedAt: Date()
//        )
//        service.addTodoItem(todoItem) { result in
//            switch result {
//            case .success(let data):
//                print(data)
//            case .failure(let error):
//                print(error)
//            }
//        }

        window.rootViewController = appCoordinator.rootViewController
        window.makeKeyAndVisible()
        return true
    }
}
