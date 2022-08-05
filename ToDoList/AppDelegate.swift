import UIKit
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)

        guard let window = window else { return false }
        let fileCache = FileCache()
        let builder = EditTaskModuleBuilder(fileCache: fileCache)
        window.rootViewController = UINavigationController(rootViewController: builder.viewController)
        window.makeKeyAndVisible()
        return true
    }
}
