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
//        service.getAllTodoItems(revision: revision) { result in
//            switch result {
//            case .success(let data):
//                print(data)
//                revision = Int(data.revision ?? 0)
//            case .failure(let error):
//                print(error)
//            }
//        }

//        service.deleteTodoItem(revision: revision, at: "36680514-56FF-4567-9599-C466C4E00BE7") { result in
//            switch result {
//            case .success(let data):
//                print(data.element)
//            case .failure(let error):
//                print(error)
//            }
//        }
        
//        let todoItem = TodoItem(
//            text: "1",
//            priority: .important,
//            deadline: Date().dayAfter,
//            createdAt: Date().noon,
//            editedAt: Date()
//        )
//        service.addTodoItem(revision: revision, todoItem) { result in
//            switch result {
//            case .success(let data):
//                print(data)
//            case .failure(let error):
//                print(error)
//            }
//        }
//
//        service.getAllTodoItems(revision: 2) { result in
//            switch result {
//            case .success(let data):
//                print(data)
//                revision = Int(data.revision ?? 0)
//            case .failure(let error):
//                print(error)
//            }
//        }

        window.rootViewController = appCoordinator.rootViewController
        window.makeKeyAndVisible()
        return true
    }
}
