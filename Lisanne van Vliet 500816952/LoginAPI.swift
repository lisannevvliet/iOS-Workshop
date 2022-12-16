//
//  LoginAPI.swift
//  Lisanne van Vliet 500816952
//
//  Created by Lisanne van Vliet on 16/11/2021.
//

import Foundation
import Combine
import KeychainAccess

final class LoginAPI: ObservableObject {
    static let shared = LoginAPI()
    
    @Published var isAuthenticated: Bool = false
    
    private var cancellable: AnyCancellable?
    private var cancellables: Set<AnyCancellable> = .init()
    private let keychain = Keychain()
    private var accessTokenKeychainKey = "accessToken"
    
    var accessToken: String? {
        get {
            try? keychain.get(accessTokenKeychainKey)
        }
        set(newValue) {
            guard let accessToken = newValue else {
                try? keychain.remove(accessTokenKeychainKey)
                isAuthenticated = false
                return
            }
            try? keychain.set(accessToken, key: accessTokenKeychainKey)
            isAuthenticated = true
        }
    }
    
    private init() {
        isAuthenticated = accessToken != nil
    }
    
    func register(username: String, password: String, completion: @escaping (Result<RegisterResponse, RequestError>) -> Void) {
        let url = URL(string: "https://inhollandbackend.azurewebsites.net/api/Users/register")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        
        let parameters = RegisterRequest(
            username: username,
            password: password
        )
        
        let encoder = JSONEncoder()
        guard let body = try? encoder.encode(parameters) else { return }
        urlRequest.httpBody = body
        
        execute(request: urlRequest, completion: completion)
    }
    
    func logIn(username: String, password: String, completion: @escaping (Result<LoginResponse, RequestError>) -> Void) {
        let url = URL(string: "https://inhollandbackend.azurewebsites.net/api/Users/login")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "POST"
        
        let parameters = LoginRequest(
            username: username,
            password: password
        )
        
        let encoder = JSONEncoder()
        guard let body = try? encoder.encode(parameters) else { return }
        urlRequest.httpBody = body
        
        execute(request: urlRequest, completion: completion)
    }
    
    func logOut() {
        accessToken = nil
        isAuthenticated = false
    }
    
    func execute<Response: Decodable>(request: URLRequest, completion: @escaping (Result<Response, RequestError>) -> Void) {
        URLSession.shared.dataTaskPublisher(for: request)
            .map({$0.data})
            .decode(type: Response.self, decoder: JSONDecoder())
            .sink { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    switch error {
                    case let urlError as URLError:
                        completion(.failure(.urlError(urlError)))
                    case let decodingError as DecodingError:
                        completion(.failure(.decodingError(decodingError)))
                    default:
                        completion(.failure(.genericError(error)))
                    }
                }
            } receiveValue: { response in
                completion(.success(response))
            }.store(in: &cancellables)
    }
}
