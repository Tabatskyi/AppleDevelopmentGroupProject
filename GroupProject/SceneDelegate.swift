import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
                let taskViewController = TaskViewController()
        taskViewController.tabBarItem = UITabBarItem(title: "Tasks", image: UIImage(systemName: "list.bullet"), tag: 0)
        
        let timerViewController = TimerViewController()
        timerViewController.tabBarItem = UITabBarItem(title: "Timer", image: UIImage(systemName: "timer"), tag: 1)
                let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: taskViewController),
            UINavigationController(rootViewController: timerViewController)
        ]
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}
