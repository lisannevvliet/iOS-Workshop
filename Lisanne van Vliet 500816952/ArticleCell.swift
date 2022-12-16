//
//  ArticleCell.swift
//  Lisanne van Vliet 500816952
//
//  Created by Lisanne van Vliet on 12/11/2021.
//

import SwiftUI

struct ArticleCell: View {
    @State private var articleImage: UIImage?
    @State private var didAppear = false
    
    let article: Article
    
    var body: some View {
        HStack {
            Text(article.title)
            
            Spacer()
            
            if let articleImage = articleImage {
                Image(uiImage: articleImage)
                    .resizable()
                    .frame(width: 50, height: 50)
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
    }
}

struct ArticleCell_Previews: PreviewProvider {
    static var previews: some View {
        ArticleCell(article: .testArticle)
    }
}
