//
//  MainViewController.swift
//  LoginTest
//
//  Created by Mehdi Zahraei on 26.06.24.
//

import UIKit

class MainViewController: UIViewController {
    
    private let authViewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        authViewModel.logout()
        navigationController?.popToRootViewController(animated: true)
        navigateToLoginView()

    }
    
    private func navigateToLoginView() {
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         if let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController") as? LoginViewController {
             loginVC.modalPresentationStyle = .fullScreen
             present(loginVC, animated: true)
         }
     }

}

