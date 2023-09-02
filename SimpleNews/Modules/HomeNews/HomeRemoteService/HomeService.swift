//
//  HomeService.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import Foundation

//struct HomeService: DataRequest {
//
//    var url: String {
//        let path: String = "mostpopular/v2/viewed/1.json"
//        return Constant.baseURL.rawValue + path
//    }
//
//    var queryItems: [String : String] {
//        [
//            "api-key": Constant.apiKey.rawValue
//        ]
//    }
//
//    var method: HTTPMethod {
//        .get
//    }
//
//    func decode(_ data: Data) throws -> [MostViewedResult] {
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-mm-dd"
//        decoder.dateDecodingStrategy = .formatted(dateFormatter)
//
//        let response = try decoder.decode(MostViewedNews.self, from: data)
//        guard let result = response.results else { return [] }
//        return result
//    }
//}

enum HomeEndpoint {
    case mostViewed
    case searchNews(query: String, page: Int)
}

extension HomeEndpoint: Endpoint {
    var queryItems: [String : String] {
        switch self {
        case .mostViewed:
            return [
                "api-key": Constant.apiKey.rawValue
            ]
            
        case .searchNews(let query, let page):
            return [
                "api-key": Constant.apiKey.rawValue,
                "q": query,
                "page": String(page)
            ]
        }
    }
    
    var path: String {
        switch self {
        case .mostViewed:
            return "/svc/mostpopular/v2/viewed/1.json"
        case .searchNews:
            return "/svc/search/v2/articlesearch.json"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .mostViewed, .searchNews:
            return .get
        }
    }

    var header: [String: String]? {
        switch self {
        case .mostViewed, .searchNews:
            return [
                "Content-Type": "application/json;charset=utf-8"
            ]
        }
    }
    
    var body: [String: String]? {
        switch self {
        case .mostViewed, .searchNews:
            return nil
        }
    }
}
