//
//  DetailViewModel.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import Foundation

protocol DetailViewModelProtocol: AnyObject {
    var newsList: [MostViewedResult] { set get }
    var newsSearchList: [SearchDoc] { set get }
    var onFetchNewsSucceed: (() -> Void)? { set get }
    var onFetchNewsFailure: ((Error) -> Void)? { set get }
    func fetchNews()
}

final class DetailViewModel: DetailViewModelProtocol {
    
    var newsList: [MostViewedResult]
    var newsSearchList: [SearchDoc]
    var onFetchNewsSucceed: (() -> Void)?
    var onFetchNewsFailure: ((Error) -> Void)?
    
    init(newsList: [MostViewedResult], newsSearchList: [SearchDoc]) {
        self.newsList = newsList
        self.newsSearchList = newsSearchList
    }
    
    func fetchNews() {
        if newsList.count > 0 {
            self.onFetchNewsSucceed?()
        } else if newsSearchList.count > 0 {
            self.onFetchNewsSucceed?()
        } else {
            self.onFetchNewsFailure?(NetworkError.invalidResponse)
        }
    }
}
