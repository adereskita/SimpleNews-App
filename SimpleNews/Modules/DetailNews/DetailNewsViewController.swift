//
//  DetailNewsViewController.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import UIKit
import CoreData

final class DetailNewsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    private let viewModel: DetailViewModel
    
    private let startAt: Int
    private var currentRowAt: Int
    private var isInitialLoad: Bool = true
    
    init(page: Int, newsList: [MostViewedResult], newsSearchList: [SearchDoc]) {
        self.startAt = page
        self.currentRowAt = page
        self.viewModel = DetailViewModel(newsList: newsList, newsSearchList: newsSearchList)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.fetchNews()
        
        setupCollectionView()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let indexPathToScroll = IndexPath(row: startAt, section: 0)
        collectionView?.scrollToItem(at: indexPathToScroll, at: .top, animated: false)
        self.collectionView?.isHidden = false
        isInitialLoad = false
    }
    
    private func setupNavigationBar() {
        var isFavorited: Bool = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Favorites", in: context)
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Favorites.fetchRequest()
        
        if viewModel.newsList.count > 0 {
            fetchRequest.predicate = NSPredicate(format: "title == %@", viewModel.newsList[currentRowAt].title ?? "")
        } else if viewModel.newsSearchList.count > 0 {
            fetchRequest.predicate = NSPredicate(format: "title == %@", viewModel.newsSearchList[currentRowAt].headline?.main ?? "")
        }
        
        do {
            let matchingObjects = try context.fetch(fetchRequest)
            isFavorited = !matchingObjects.isEmpty

        } catch {
            print("context error")
        }
        
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: isFavorited ? "star.fill" : "star")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        
        self.title = "News Detail"
        navigationController?.navigationBar.backgroundColor = .white
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView?.collectionViewLayout = layout
        
        collectionView?.isPagingEnabled = true
        
        collectionView?.register(DetailNewsCollectionViewCell.nib(), forCellWithReuseIdentifier: DetailNewsCollectionViewCell.identifier())
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.isHidden = true
    }
    
    private func bindViewModel() {
        viewModel.onFetchNewsSucceed = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.collectionView?.reloadData()
            }
        }
    }
    
    @objc private func favoriteButtonTapped() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Favorites", in: context)
//        let newFav = Favorites(entity: entity!, insertInto: context)
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Favorites.fetchRequest()
        
        if viewModel.newsList.count > 0 {
            fetchRequest.predicate = NSPredicate(format: "title == %@", viewModel.newsList[currentRowAt].title ?? "")
            
            do {
                let matchingObjects = try context.fetch(fetchRequest)
                
                if !matchingObjects.isEmpty {
                    return
                }
            } catch {
                print("context error")
            }
            
            let newFav = Favorites(entity: entity!, insertInto: context)

            newFav.title = viewModel.newsList[currentRowAt].title
            newFav.snippets = viewModel.newsList[currentRowAt].abstract
            newFav.image = viewModel.newsList[currentRowAt].media?.first?.mediaMetadata?.first { $0.format == "mediumThreeByTwo440" }?.url
            newFav.date = viewModel.newsList[currentRowAt].publishedDate?.convertToDateFormat()
            
        } else if viewModel.newsSearchList.count > 0 {
            fetchRequest.predicate = NSPredicate(format: "title == %@", viewModel.newsSearchList[currentRowAt].headline?.main ?? "")
            
            do {
                let matchingObjects = try context.fetch(fetchRequest)
                
                if !matchingObjects.isEmpty {
                    return
                }
            } catch {
                print("context error")
            }

            let newFav = Favorites(entity: entity!, insertInto: context)

            newFav.title = viewModel.newsSearchList[currentRowAt].headline?.main
            newFav.snippets = viewModel.newsSearchList[currentRowAt].snippet
            newFav.image = viewModel.newsSearchList[currentRowAt].multimedia?.first { $0.subtype == "mediumThreeByTwo440" }?.url
            newFav.date = viewModel.newsSearchList[currentRowAt].pubDate?.convertFromISO8601Format()
        }
        
        do {
            try context.save()
            
            let favoriteButton = UIBarButtonItem(
                image: UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal),
                style: .plain,
                target: self,
                action: #selector(favoriteButtonTapped)
            )
            navigationItem.rightBarButtonItem = favoriteButton
        } catch {
            print("context save error")
        }
    }
}

extension DetailNewsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if viewModel.newsList.count > 0 {
            return viewModel.newsList.count
        } else if viewModel.newsSearchList.count > 0 {
            return viewModel.newsSearchList.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DetailNewsCollectionViewCell.identifier(), for: indexPath) as? DetailNewsCollectionViewCell else { return UICollectionViewCell() }
        
        if viewModel.newsList.count > 0 {
            let data = viewModel.newsList[indexPath.row]
            cell.setupUI(with: data)
            
        } else if viewModel.newsSearchList.count > 0 {
            let data = viewModel.newsSearchList[indexPath.row]
            cell.setupUI(withSearch: data)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / 1.5)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            let visibleIndexPaths = collectionView.indexPathsForVisibleItems
            for indexPath in visibleIndexPaths {
                if !isInitialLoad {
                    let row = indexPath.row
                    self.currentRowAt = row
                }
            }
        }
    }
}
