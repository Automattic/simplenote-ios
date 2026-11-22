import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var appDelegate: SPAppDelegate {
        SPAppDelegate.shared()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        appDelegate.connectWindow(window)

        for context in connectionOptions.urlContexts {
            appDelegate.handleURL(context.url)
        }

        for userActivity in connectionOptions.userActivities {
            appDelegate.handleUserActivity(userActivity)
        }

        if let shortcutItem = connectionOptions.shortcutItem {
            ShortcutsHandler.shared.handleApplicationShortcut(shortcutItem)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        appDelegate.disconnectWindow()
        window = nil
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        appDelegate.didBecomeActive()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        appDelegate.willResignActive()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        appDelegate.willEnterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        appDelegate.didEnterBackground()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        for context in URLContexts {
            appDelegate.handleURL(context.url)
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        appDelegate.handleUserActivity(userActivity)
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        ShortcutsHandler.shared.handleApplicationShortcut(shortcutItem)
        completionHandler(true)
    }
}
