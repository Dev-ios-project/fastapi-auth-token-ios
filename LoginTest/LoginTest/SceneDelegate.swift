//
//  SceneDelegate.swift
//  LoginTest
//
//  Created by Mehdi Zahraei on 26.06.24.
//

// SceneDelegate.swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var authViewModel = AuthViewModel()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if authViewModel.isAuthenticated {
            // Instantiate MainViewController
            let mainVC = storyboard.instantiateViewController(identifier: "MainViewController") as! MainViewController
            window?.rootViewController = mainVC
        } else {
            // Instantiate LoginViewController
            let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            window?.rootViewController = loginVC
        }
        
        window?.makeKeyAndVisible()
    }

    // other SceneDelegate methods...
}


