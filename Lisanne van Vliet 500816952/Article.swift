//
//  Article.swift
//  Lisanne van Vliet 500816952
//
//  Created by Lisanne van Vliet on 12/11/2021.
//

import Foundation

struct Article: Identifiable, Decodable {
    let id = UUID()
    let apiID: Int
    let title: String
    let summary: String
    let image: URL
    let url: URL
    
    enum CodingKeys: String, CodingKey {
        case apiID = "Id"
        case title = "Title"
        case summary = "Summary"
        case image = "Image"
        case url = "Url"
    }
    
    static var testArticle = Article(
        apiID: 134069,
        title: "Van der Breggen en Blaak kondigen afscheid aan als wielrenster",
        summary: "Anna van der Breggen en Chantal Blaak hebben zondag hun afscheid aangekondigd als wielrenster. De wereldtoppers stoppen over respectievelijk anderhalf en twee jaar en gaan daarna verder als ploegleidster.",
        image: URL(string: "https://media.nu.nl/m/k3zx972ap9ap_sqr256.jpg/van-der-breggen-en-blaak-kondigen-afscheid-aan-als-wielrenster.jpg")!,
        url: URL(string: "https://www.nu.nl/wielrennen/6050336/van-der-breggen-en-blaak-kondigen-afscheid-aan-als-wielrenster.html")!)
}

struct GetArticlesResponse: Decodable {
    let articles: [Article]
    
    enum CodingKeys: String, CodingKey {
        case articles = "Results"
    }
}
