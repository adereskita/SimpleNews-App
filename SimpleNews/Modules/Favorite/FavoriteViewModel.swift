//
//  FavoriteViewModel.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import UIKit
import CoreData

protocol FavoriteViewModelProtocol: AnyObject {
    var newsList: [Favorites] { set get }
    var onFetchNewsSucceed: (() -> Void)? { set get }
    var onFetchNewsFailure: ((Error) -> Void)? { set get }
    func fetchFavoriteNews()
}

final class FavoriteViewModel: FavoriteViewModelProtocol {
    
    var newsList: [Favorites] = []
    var onFetchNewsSucceed: (() -> Void)?
    var onFetchNewsFailure: ((Error) -> Void)?
    
    func fetchFavoriteNews() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        do {
            let results: NSArray = try context.fetch(request) as NSArray
            for result in results {
                guard let favorites = result as? Favorites else { return }
                newsList.append(favorites)
            }
        } catch {
            print("Fetch Failed")
        }
    }
}
