//
//  HomeViewModel.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import UIKit
import CoreData

protocol HomeViewModelProtocol: AnyObject {
    var newsList: [MostViewedResult] { set get }
    var newsSearchList: [SearchDoc] { set get }
    var searchSuggestion: [String] { set get }
    var onFetchNewsSucceed: (() -> Void)? { set get }
    var onFetchNewsFailure: ((Error) -> Void)? { set get }
    func saveOffline(newsList: [MostViewedResult])
    func fetchMostViewedNews()
    func fetchSearchNews(query: String, page: Int)
    func fetchOffilneData()
    func addSuggestions(text: String)
}

final class HomeViewModel: HomeViewModelProtocol {
    
    private let networkService: HomeNetworkServiceProtocol
    
    init(networkService: HomeNetworkServiceProtocol = HomeNetworkService()) {
        self.networkService = networkService
    }
    
    var newsList: [MostViewedResult] = []
    var newsSearchList: [SearchDoc] = []
    var searchSuggestion: [String] = []
    var onFetchNewsSucceed: (() -> Void)?
    var onFetchSearchNewsSucceed: (() -> Void)?
    var onFetchNewsFailure: ((Error) -> Void)?
    
    func fetchMostViewedNews() {
        networkService.getMostViewed { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let value):
                self.newsList = value.results ?? []
                self.onFetchNewsSucceed?()
            case .failure(let error):
                self.onFetchNewsFailure?(error)
            }
        }
    }
    
    func fetchSearchNews(query: String, page: Int) {
        networkService.getSearchNews(query: query, page: page) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let value):
                self.newsSearchList += value.response?.docs ?? []
                self.onFetchNewsSucceed?()
            case .failure(let error):
                self.onFetchNewsFailure?(error)
            }
        }
    }
    
    func fetchOffilneData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Offline")
        do {
            let results: NSArray = try context.fetch(request) as NSArray
            for result in results {
                guard let offline = result as? Offline else { return }
                let newsModel = MostViewedResult(uri: nil, url: nil, id: nil, assetID: nil, source: nil, publishedDate: offline.date, updated: nil, section: nil, subsection: nil, nytdsection: nil, adxKeywords: nil, byline: nil, type: nil, title: offline.title, abstract: offline.snippets, desFacet: [], orgFacet: [], perFacet: [], geoFacet: [], media: [Media(type: nil, subtype: nil, caption: nil, copyright: nil, approvedForSyndication: nil, mediaMetadata: [MediaMeta(url: offline.image, format: "mediumThreeByTwo440", height: nil, width: nil)])], etaID: nil)
                
                newsList.append(newsModel)
            }
            self.onFetchNewsSucceed?()
        } catch {
            print("Fetch Failed")
            self.onFetchNewsFailure?(error)
        }
    }
    
    func saveOffline(newsList: [MostViewedResult]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Offline.fetchRequest()
        
        for (index, data) in newsList.enumerated() {
            do {
                let count = try context.count(for: fetchRequest)
                if index > 10 || count > 10 {
                    break
                }
            } catch {
                print("context error")
            }
            
            let entity = NSEntityDescription.entity(forEntityName: "Offline", in: context)
            let newOffline = Offline(entity: entity!, insertInto: context)
            
            newOffline.title = data.title
            newOffline.snippets = data.abstract
            newOffline.image = data.media?.first?.mediaMetadata?.first { $0.format == "mediumThreeByTwo440" }?.url
            newOffline.date = data.publishedDate?.convertToDateFormat()
            
            do {
                let count = try context.count(for: fetchRequest)
                if count <= 10 {
                    try context.save()
                }
            } catch {
                print("context save error")
            }
        }
    }
    
    func addSuggestions(text: String) {        
        if let existingIndex = searchSuggestion.firstIndex(of: text) {
            searchSuggestion.remove(at: existingIndex)
        }
        
        searchSuggestion.append(text)
        
        if searchSuggestion.count > 10 {
            let excessCount = searchSuggestion.count - 10
            searchSuggestion.removeFirst(excessCount)
        }
    }
}
