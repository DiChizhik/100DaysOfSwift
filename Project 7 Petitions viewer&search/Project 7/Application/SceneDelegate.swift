//
//  SceneDelegate.swift
//  Project 7
//
//  Created by Diana Chizhik on 17/05/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        /// The app hierarchy will be:
        ///
        ///  UITabbarController
        ///     |- UINavigationController
        ///         |- UIViewController
        ///     |- UINavigationController
        ///         |- UIViewController
        
        // First Main Tabbar
        let tabBarController = UITabBarController()
        
        // First navigation controller with its root
        let mostRecentPetitionViewController = MostRecentPetitionsViewController()
        let firstTabNavigationController = UINavigationController(rootViewController: mostRecentPetitionViewController)
        firstTabNavigationController.tabBarItem.image = UIImage(systemName: "clock.fill")
        firstTabNavigationController.tabBarItem.title = "Most recent"
        
        // Second navigation with its root
        let topRatedPetitionsViewController = TopRatedPetitionsViewController()
        let secondTabNavigationController = UINavigationController(rootViewController: topRatedPetitionsViewController)
        secondTabNavigationController.tabBarItem.image = UIImage(systemName: "star.fill")
        secondTabNavigationController.tabBarItem.title = "Top rated"
        
        // Configure tabbar
        tabBarController.viewControllers = [
            firstTabNavigationController,
            secondTabNavigationController
        ]
        
        // Create our own UIWindow from the scene provided.
        window = UIWindow(windowScene: windowScene)
        
        // Set tabbar as root of our window
        window?.rootViewController = tabBarController
        
        // Make key and visible
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

