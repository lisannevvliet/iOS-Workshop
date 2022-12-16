//
//  ContentView.swift
//  Lisanne van Vliet 500816952
//
//  Created by Lisanne van Vliet on 12/11/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var articles: [Article] = []
    @State private var articleImage: UIImage?
    @State var error: String = ""
    
    static let shared = ContentView()
    
    var body: some View {
        NavigationView {
            List(articles) { article in
                NavigationLink(destination: {
                    ArticleDetailView(article: article)
                }, label: {
                    ArticleCell(article: article)
                })
            }
            .onAppear {
                ArticleAPI.shared.getArticles { result in
                    switch result {
                    case .success(let getArticleResponse):
                        self.error = ""
                        articles = getArticleResponse.articles
                    case .failure(let error):
                        switch error {
                        case .urlError(let urlError):
                            self.error = "\(urlError.localizedDescription)"
                        case .decodingError(let decodingError):
                            self.error = "\(decodingError.localizedDescription)"
                        case .genericError(let error):
                            self.error = "\(error.localizedDescription)"
                        }
                    }
                }
            }
            .refreshable {
                ArticleAPI.shared.getArticles { result in
                    switch result {
                    case .success(let getArticleResponse):
                        self.error = ""
                        articles = getArticleResponse.articles
                    case .failure(let error):
                        switch error {
                        case .urlError(let urlError):
                            self.error = "\(urlError.localizedDescription)"
                        case .decodingError(let decodingError):
                            self.error = "\(decodingError.localizedDescription)"
                        case .genericError(let error):
                            self.error = "\(error.localizedDescription)"
                        }
                    }
                }
            }
            .navigationBarItems(
                leading:
                    HStack {
                        if LoginAPI.shared.isAuthenticated == true {
                            Button {
                                LoginAPI.shared.logOut()
                                // Refresh the view so that the navigation bar items change accordingly.
                                ArticleAPI.shared.getArticles { result in
                                    switch result {
                                    case .success(let getArticleResponse):
                                        self.error = ""
                                        articles = getArticleResponse.articles
                                    case .failure(let error):
                                        switch error {
                                        case .urlError(let urlError):
                                            self.error = "\(urlError.localizedDescription)"
                                        case .decodingError(let decodingError):
                                            self.error = "\(decodingError.localizedDescription)"
                                        case .genericError(let error):
                                            self.error = "\(error.localizedDescription)"
                                        }
                                        
                                    }
                                }
                            } label: {
                                Label("Escape", systemImage: "escape")
                            }
                        }
                    }
                , trailing:
                    NavigationLink(destination: {
                        if LoginAPI.shared.isAuthenticated == true {
                            FavoritesView()
                        } else {
                            LoginView()
                        }
                    }, label: {
                        if LoginAPI.shared.isAuthenticated == true {
                            Image(systemName: "star.fill")
                        } else {
                            Text("Log in")
                        }
                    })
            )
            .navigationTitle("News List")
        }
        
        if error != "" {
            Text(error)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environment(\.locale, .init(identifier: "en"))
            
            ContentView()
                .environment(\.locale, .init(identifier: "nl"))
        }
    }
}
