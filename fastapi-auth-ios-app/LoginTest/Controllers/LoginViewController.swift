import UIKit
import Combine

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupLabel: UILabel!
    
    private var viewModel = AuthViewModel()
    private var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Observe the isAuthenticated property
        viewModel.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.navigateToMainView()
                }
            }
            .store(in: &cancellables)
        
        // Add tap gesture recognizer tonthe Label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(registerLabelTapped))
        signupLabel.isUserInteractionEnabled=true
        signupLabel.addGestureRecognizer(tapGesture)
        
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let username = usernameTextField.text, let password = passwordTextField.text else {
            return
        }

        viewModel.login(username: username, password: password) { success in
            if !success {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: "Login failed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    @objc func registerLabelTapped(){
        performSegue(withIdentifier: "ShowRegister", sender: self)
    }
    
    

    private func navigateToMainView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(identifier: "MainViewController") as? MainViewController {
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true)
        }
    }
    
    
}
