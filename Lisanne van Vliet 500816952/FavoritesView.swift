//
//  FavoritesView.swift
//  Lisanne van Vliet 500816952
//
//  Created by Lisanne van Vliet on 16/11/2021.
//

import SwiftUI

struct FavoritesView: View {
    @State private var favoriteArticles: [Article] = []
    
    static let shared = ContentView()
    
    var body: some View {
        List(favoriteArticles) { article in
            NavigationLink(destination: {
                ArticleDetailView(article: article)
            }, label: {
                ArticleCell(article: article)
            })
        }
        .onAppear {
            ArticleAPI.shared.getFavoriteArticles { result in
                switch result {
                case .success(let getArticleResponse):
                    favoriteArticles = getArticleResponse.articles
                case .failure(let error):
                    switch error {
                    case .urlError(let urlError):
                        print("\(urlError.localizedDescription)")
                    case .decodingError(let decodingError):
                        print("\(decodingError.localizedDescription)")
                    case .genericError(let error):
                        print("\(error.localizedDescription)")
                    }
                }
            }
        }
        .refreshable {
            ArticleAPI.shared.getFavoriteArticles { result in
                switch result {
                case .success(let getArticleResponse):
                    favoriteArticles = getArticleResponse.articles
                case .failure(let error):
                    switch error {
                    case .urlError(let urlError):
                        print("\(urlError.localizedDescription)")
                    case .decodingError(let decodingError):
                        print("\(decodingError.localizedDescription)")
                    case .genericError(let error):
                        print("\(error.localizedDescription)")
                    }
                }
            }
        }
        .navigationTitle("Favorites")
        
        Spacer()
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                FavoritesView()
                    .environment(\.locale, .init(identifier: "en"))
            }
            
            NavigationView {
                FavoritesView()
                    .environment(\.locale, .init(identifier: "nl"))
            }
        }
    }
}
