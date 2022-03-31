//
//  AppDelegate.swift
//  Weather
//
//  Created by Евгений Ерофеев on 28.03.22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate, UIWindowSceneDelegate {
    var window: UIWindow?
    var tabBarController: UITabBarController?
    var viewController: UIViewController? {
        let navController = tabBarController?.selectedViewController as? UINavigationController
        return navController?.visibleViewController
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        tabBarController = UITabBarController()
        tabBarController?.delegate = self

        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        let todayweatherVC = ModulBuilder.createTodayWeatherModule()
        let forecastweatherVC = ModulBuilder.createForecastWeatherModule()

        let tabViews = [todayweatherVC, forecastweatherVC]

        todayweatherVC.title = "Today"
        forecastweatherVC.title = "Forecast"
        
        if #available(iOS 13.0, *) {
            todayweatherVC.tabBarItem = UITabBarItem(
                title: "Today",
                image: UIImage(systemName: "sun.max"),
                selectedImage: nil
            )
            forecastweatherVC.tabBarItem = UITabBarItem(
                title: "Forecast",
                image: UIImage(systemName: "cloud.sun"),
                selectedImage: nil
            )
        } else {
            todayweatherVC.tabBarItem = UITabBarItem(title: "Today", image: nil, selectedImage: nil)
            forecastweatherVC.tabBarItem = UITabBarItem(title: "Forecast", image: nil, selectedImage: nil)
        }

        tabBarController?.viewControllers = tabViews.compactMap { UINavigationController(rootViewController: $0) }
        tabBarController?.tabBar.tintColor = UIColor(named: "colorForHeaders")
        tabBarController?.tabBar.unselectedItemTintColor = .darkGray
        tabBarController?.tabBar.tintColor = .systemRed
        tabBarController?.tabBar.barTintColor = UIColor(named: "colorForHeaders")

        UINavigationBar.appearance().tintColor = UIColor(named: "secondaryBackground")
        
        window?.backgroundColor = UIColor(named: "secondaryBackground")
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        /* Called when the user discards a scene session.
         If any sessions were discarded while the application was not running,
         this will be called shortly after application:didFinishLaunchingWithOptions.
         Use this method to release any resources that were specific to the discarded scenes, as they will not return.
 */
    }
}
