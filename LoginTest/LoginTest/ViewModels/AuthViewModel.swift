import Foundation
import Combine
import KeychainAccess

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    private var cancellables = Set<AnyCancellable>()
    private let keychain = Keychain(service: "com.example.myapp")
    private let baseUrl = "http://127.0.0.1:8000"
    
    init() {
        if let token = keychain["token"], !token.isEmpty {
            isAuthenticated = true
        }
    }

    func login(username: String, password: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseUrl)/user/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let bodyComponents = "username=\(username)&password=\(password)"
        request.httpBody = bodyComponents.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(false)
                return
            }
            guard let data = data else {
                completion(false)
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
            }
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                DispatchQueue.main.async {
                    self.keychain["token"] = tokenResponse.access_token
                    self.isAuthenticated = true
                    completion(true)
                }
            } catch {
                print("Decoding error: \(error)")
                completion(false)
            }
        }.resume()
    }

    func logout() {
        keychain["token"] = nil
        isAuthenticated = false
    }
}
