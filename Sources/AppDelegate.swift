import UIKit
#if CARPLAY
import CarPlay
#endif

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting session: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "ParkView", sessionRole: session.role)
        #if CARPLAY
        if session.role == CPTemplateApplicationSceneSessionRoleApplication {
            config.sceneClass = CPTemplateApplicationScene.self
            config.delegateClass = CarPlaySceneDelegate.self
            return config
        }
        #endif
        config.delegateClass = PhoneSceneDelegate.self
        return config
    }
}

final class PhoneSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }
        let tabs = UITabBarController()
        let controllers: [(UIViewController, String, String)] = [
            (BrowserController(), "Navegador", "globe"),
            (VideoController(), "Vídeo / AirPlay", "play.rectangle"),
            (DiagnosticsController(), "Diagnóstico", "waveform.path.ecg")
        ]
        tabs.viewControllers = controllers.map { controller, title, icon in
            controller.title = title
            let navigation = UINavigationController(rootViewController: controller)
            navigation.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: icon), tag: 0)
            return navigation
        }
        let window = UIWindow(windowScene: scene)
        window.rootViewController = tabs
        window.makeKeyAndVisible()
        self.window = window
        Diagnostics.shared.record("Interface do iPhone iniciada")
    }
}
