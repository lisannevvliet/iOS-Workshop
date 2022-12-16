//
//  ArticleDetailView.swift
//  Lisanne van Vliet 500816952
//
//  Created by Lisanne van Vliet on 12/11/2021.
//

import SwiftUI

struct ArticleDetailView: View {
    @State private var favoriteArticles: [Article] = []
    @State private var articleImage: UIImage?
    @State private var star: String = "star"
    @State private var filledStar: String = "star.fill"
    @State private var didAppear = false
    
    let article: Article
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                if let article = article {
                    Text(article.title)
                        .font(.title)
                    
                    Text(article.summary)
                    
                    if let articleImage = articleImage {
                        Image(uiImage: articleImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(5)
                            .onAppear {
                                didAppear = true
                            }
                            .opacity(didAppear ? 1 : 0)
                            .animation(.linear(duration: 0.5))
                    } else {
                        ProgressView("Image is loading.")
                            .onAppear {
                                ArticleAPI.shared.getArticleImage(article: article) { result in
                                    switch result {
                                    case .success(let articleImage):
                                        self.articleImage = articleImage
                                    case .failure(let error):
                                        switch error {
                                        default:
                                            print("\(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                    }
                }
                
                Link(destination: article.url) {
                    Text("\(article.url)")
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .onAppear {
                getFavoriteArticles()
            }
            .navigationBarItems(
                trailing:
                    HStack {
                        if LoginAPI.shared.isAuthenticated == true {
                            Button {
                                if favoriteArticles.contains(where: { $0.apiID == article.apiID }) {
                                    ArticleAPI.shared.dislikeArticle(id: article.apiID) { result in
                                        switch result {
                                        case .success(_):
                                            break
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
                                        
                                        star = "star"
                                        filledStar = "star"
                                        
                                        getFavoriteArticles()
                                    }
                                } else {
                                    ArticleAPI.shared.likeArticle(id: article.apiID) { result in
                                        switch result {
                                        case .success(_):
                                            break
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
                                        
                                        star = "star.fill"
                                        filledStar = "star.fill"
                                        
                                        getFavoriteArticles()
                                    }
                                }
                            } label: {
                                if favoriteArticles.contains(where: { $0.apiID == article.apiID }) {
                                    Label("Star", systemImage: "\(filledStar)")
                                } else {
                                    Label("Star", systemImage: "\(star)")
                                }
                            }
                        }
                        
                        Button {
                            guard let urlShare = URL(string: "\(article.url)") else { return }
                            let activityVC = UIActivityViewController(activityItems: [urlShare], applicationActivities: nil)
                            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
                            
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                activityVC.popoverPresentationController?.sourceView = UIApplication.shared.windows.first
                                activityVC.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width, y: -125, width: 200, height: 200)
                                activityVC.popoverPresentationController?.permittedArrowDirections = .up
                            }
                        } label: {
                            Label("Square and arrow up", systemImage: "square.and.arrow.up")
                        }
                    }
            )
            .navigationTitle("News Details")
        }
    }
    
    func getFavoriteArticles() {
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
}

struct ArticleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ArticleDetailView(article: .testArticle)
        }
    }
}
