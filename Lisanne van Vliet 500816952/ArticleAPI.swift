//
//  ArticleAPI.swift
//  Lisanne van Vliet 500816952
//
//  Created by Lisanne van Vliet on 12/11/2021.
//

import Combine
import Foundation
import UIKit

class ArticleAPI {
    static let shared = ArticleAPI()
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    func getArticles(completion: @escaping (Result<GetArticlesResponse, RequestError>) -> Void) {
        guard let url: URL = .init(string: "https://inhollandbackend.azurewebsites.net/api/Articles") else { return }
        let request = URLRequest(url: url)
        
        execute(request: request, completion: completion)
    }
    
    func getFavoriteArticles(completion: @escaping (Result<GetArticlesResponse, RequestError>) -> Void) {
        let url = URL(string: "https://inhollandbackend.azurewebsites.net/api/Articles/liked")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(LoginAPI.shared.accessToken, forHTTPHeaderField: "x-authtoken")
        urlRequest.httpMethod = "GET"
        
        execute(request: urlRequest, completion: completion)
    }
    
    func likeArticle(id: Int, completion: @escaping (Result<String, RequestError>) -> Void) {
        let url = URL(string: "https://inhollandbackend.azurewebsites.net/api/Articles/\(id)//like")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(LoginAPI.shared.accessToken, forHTTPHeaderField: "x-authtoken")
        urlRequest.httpMethod = "PUT"
        
        URLSession.shared.dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(.genericError(error)))
                }
            }) { (response) in
                completion(.success("success"))
            }.store(in: &cancellables)
    }
    
    func dislikeArticle(id: Int, completion: @escaping (Result<String, RequestError>) -> Void) {
        let url = URL(string: "https://inhollandbackend.azurewebsites.net/api/Articles/\(id)//like")!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue(LoginAPI.shared.accessToken, forHTTPHeaderField: "x-authtoken")
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTaskPublisher(for: urlRequest)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(.genericError(error)))
                }
            }) { (response) in
                completion(.success("success"))
            }.store(in: &cancellables)
    }
    
    func getArticleImage(article: Article, completion: @escaping (Result<UIImage, RequestError>) -> Void) {
        let request = URLRequest(url: article.image)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map({ UIImage(data: $0.data) ?? UIImage() })
            .sink { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(.urlError(error)))
                }
            } receiveValue: { articleImage in
                completion(.success(articleImage))
            }.store(in: &cancellables)
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
            }
            .store(in: &cancellables)
    }
}

enum RequestError: Error {
    case urlError(URLError)
    case decodingError(DecodingError)
    case genericError(Error)
}
