//
//  Favorites.swift
//  SimpleNews
//
//  Created by Ade on 9/2/23.
//

import Foundation
import CoreData

@objc(Favorites)
class Favorites: NSManagedObject {
    @NSManaged var title: String?
    @NSManaged var snippets: String?
    @NSManaged var image: String?
    @NSManaged var date: String?
}
