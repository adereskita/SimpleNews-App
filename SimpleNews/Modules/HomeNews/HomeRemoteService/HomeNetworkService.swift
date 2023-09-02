//
//  HomeNetworkService.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import Foundation

protocol HomeNetworkServiceProtocol {
//    func getMostViewed() async -> Result<MostViewedNews, RequestError>
    func getMostViewed(completionHandler: @escaping (Result<MostViewedNews, RequestError>) -> Void)
    func getSearchNews(query: String, page: Int, completionHandler: @escaping (Result<SearchNews, RequestError>) -> Void)
}

class HomeNetworkService: HTTPClient, HomeNetworkServiceProtocol {
    func getSearchNews(query: String, page: Int, completionHandler: @escaping (Result<SearchNews, RequestError>) -> Void) {
        sendRequest(endpoint: HomeEndpoint.searchNews(query: query, page: page), responseModel: SearchNews.self) { result in
            completionHandler(result)
        }
    }
    
    func getMostViewed(completionHandler: @escaping (Result<MostViewedNews, RequestError>) -> Void) {
        sendRequest(endpoint: HomeEndpoint.mostViewed, responseModel: MostViewedNews.self, completionHandler: { result in
            completionHandler(result)
        })
    }
}
