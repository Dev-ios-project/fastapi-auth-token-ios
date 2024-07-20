//
//  RegisterViewController.swift
//  LoginTest
//
//  Created by Mehdi Zahraei on 20.07.24.
//

import Foundation
import UIKit

class RegisterViewController: UIViewController{
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    let authViewModel = AuthViewModel()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            
            // Add observers for keyboard events
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
            // Add gesture recognizer to dismiss keyboard
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tapGesture)
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        @objc func keyboardWillShow(notification: NSNotification) {
            if let userInfo = notification.userInfo,
               let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
                scrollView.contentInset = contentInsets
                scrollView.scrollIndicatorInsets = contentInsets
            }
        }

        @objc func keyboardWillHide(notification: NSNotification) {
            let contentInsets = UIEdgeInsets.zero
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }

        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
    
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = usernameTextField.text, !password.isEmpty,
              let conformpassword = confirmPasswordTextField.text, !conformpassword.isEmpty else {
            showAlert(title: "Error", message: "Please enter all  credentials")
            return
        }
        
        
        guard password == conformpassword else{
            showAlert(title: "error", message: "password do nor match")
            return
        }
        
        authViewModel.register(username: username, password: password ){ success, message in
                
            DispatchQueue.main.async {
                if success {
                    self.showAlert(title: "Success", message: "Register successful"){
                        self.dismiss(animated: true,completion: nil)
                    }
                } else {
                    self.showAlert(title: "Error", message: "Register failed")
                }
            }
                
        }
        
    }
    
    //Custom Alert
    private func showAlert(title: String, message:String, completion:(()-> Void)? = nil){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default){ _ in
            completion?()
        })
        present(alertController,animated: true,completion: nil)
    }
    
    
}
