//
//  FavoriteViewController.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import UIKit
import CoreData

class FavoriteViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView?
    
    private let viewModel: FavoriteViewModel
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = FavoriteViewModel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.fetchFavoriteNews()
        
        setupNavigationBar()
        setupCollectionView()
    }
    
    private func setupNavigationBar() {
        self.title = "Favorite News"
    }
    
    private func setupCollectionView() {
        let layout = HomeCollectionFlowLayout(isSuggestion: false)
        collectionView?.collectionViewLayout = layout
        
        collectionView?.register(NewsListCollectionViewCell.nib(), forCellWithReuseIdentifier: NewsListCollectionViewCell.identifier())
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
    }
    
    private func routeToDetail(at page: Int) {
        var newsModel: [MostViewedResult] = []
        for item in viewModel.newsList {
            let model = MostViewedResult(uri: nil, url: nil, id: nil, assetID: nil, source: nil, publishedDate: item.date, updated: nil, section: nil, subsection: nil, nytdsection: nil, adxKeywords: nil, byline: nil, type: nil, title: item.title, abstract: item.snippets, desFacet: [], orgFacet: [], perFacet: [], geoFacet: [], media: [Media(type: nil, subtype: nil, caption: nil, copyright: nil, approvedForSyndication: nil, mediaMetadata: [MediaMeta(url: item.image, format: "mediumThreeByTwo440", height: nil, width: nil)])], etaID: nil)
            newsModel.append(model)
        }
        
        let vc = DetailNewsViewController(page: page, newsList: newsModel, newsSearchList: [])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Favorites.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", viewModel.newsList[indexPath.row].title ?? "")

        do {
            let fetchedResults = try context.fetch(fetchRequest)

            for object in fetchedResults {
                if let objectData = object as? NSManagedObject {
                    context.delete(objectData)
                }
            }

            try context.save()
        } catch {
            print("Error deleting data: \(error)")
        }
        
        let indexPathToRemove = IndexPath(item: indexPath.row, section: indexPath.section)

        viewModel.newsList.remove(at: indexPath.row)
        collectionView?.deleteItems(at: [indexPathToRemove])
    }
}

extension FavoriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.newsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsListCollectionViewCell.identifier(), for: indexPath) as? NewsListCollectionViewCell else { return UICollectionViewCell() }
        
        let data = viewModel.newsList[indexPath.row]
        
        cell.setupUI(withFavorites: data, isImageSmaller: UIDevice.current.orientation.isLandscape)
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        routeToDetail(at: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), identifier: nil) { [weak self] _ in
            self?.deleteItem(at: indexPath)
            self?.collectionView?.reloadData()
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            UIMenu(title: "", children: [deleteAction])
        }
    }
}
