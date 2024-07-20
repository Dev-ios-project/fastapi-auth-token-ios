import Foundation
import Combine
import KeychainAccess


struct RegisterResponse:Codable{
    let message: String
}

struct ErrorResponse:Codable{
    let detail: String?
}




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
    
    
    func register(username: String, password: String, completion: @escaping (Bool, String?) -> Void) {
            guard let url = URL(string: "\(baseUrl)/user/create") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let json: [String: Any] = ["username": username, "password": password]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
                completion(false, "Invalid input data")
                return
            }

            request.httpBody = jsonData

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                    DispatchQueue.main.async {
                        completion(false, error.localizedDescription)
                    }
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        completion(false, "Invalid response from server")
                    }
                    return
                }

                guard let data = data else {
                    DispatchQueue.main.async {
                        completion(false, "No data received")
                    }
                    return
                }

                // Print raw data for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response Data: \(responseString)")
                }

                do {
                    if httpResponse.statusCode == 400 {
                        // Handle specific error for username already registered
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        let errorMessage = errorResponse.detail ?? "Username already registered"
                        DispatchQueue.main.async {
                            completion(false, errorMessage)
                        }
                    } else if httpResponse.statusCode == 200 {
                        // Handle successful registration
                        let registerResponse = try JSONDecoder().decode(RegisterResponse.self, from: data)
                        DispatchQueue.main.async {
                            completion(true, registerResponse.message)
                        }
                    } else {
                        // Handle unexpected status codes
                        DispatchQueue.main.async {
                            completion(false, "Unexpected error")
                        }
                    }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completion(false, "Data decoding error")
                    }
                }
            }.resume()
        }

    func logout() {
        keychain["token"] = nil
        isAuthenticated = false
    }
}
