//
//  HomeViewController.swift
//  SimpleNews
//
//  Created by Ade on 8/31/23.
//

import UIKit
import Network

final class HomeViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let viewModel: HomeViewModel
    
    private var isLoadingData = false
    private var isSearching: Bool = false
    private var isSearchEmptyState: Bool = false {
        didSet {
            collectionView?.layoutIfNeeded()
            collectionView?.layoutSubviews()
        }
    }
    private var currentPage = 1
    private var searchText = ""
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.viewModel = HomeViewModel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)

        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                // Internet is reachable
                print("Internet is reachable")
                self.viewModel.fetchMostViewedNews()
            } else {
                // Internet is not reachable
                print("Internet is not reachable")
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.viewModel.fetchOffilneData()
                }
            }
        }
        
        setupNavigationBar()
        setupSearchController()
        setupCollectionView()
        bindViewModel()
        
        /// Update the layout on device orientation changes
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollectionViewLayout), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setupNavigationBar() {
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: "star.fill")?.withTintColor(.systemYellow, renderingMode: .alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        
        self.title = "Home News"
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    private func setupSearchController() {
        searchController.loadViewIfNeeded()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = false
        searchController.searchBar.returnKeyType = .done
        
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.placeholder = "Search News"
    }
    
    private func bindViewModel() {
        viewModel.onFetchNewsSucceed = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.isLoadingData = false
                self.collectionView?.reloadData()
                self.viewModel.saveOffline(newsList: self.viewModel.newsList)
            }
        }
        
        viewModel.onFetchSearchNewsSucceed = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.isLoadingData = false
                self.collectionView?.reloadData()
            }
        }
    }

    private func setupCollectionView() {
        let layout = HomeCollectionFlowLayout(isSuggestion: isSearchEmptyState)
        collectionView?.collectionViewLayout = layout
        
        collectionView?.register(NewsListCollectionViewCell.nib(), forCellWithReuseIdentifier: NewsListCollectionViewCell.identifier())
        collectionView?.register(SearchSuggestionCollectionViewCell.self, forCellWithReuseIdentifier: SearchSuggestionCollectionViewCell.reuseIdentifier)
        
        collectionView?.delegate = self
        collectionView?.dataSource = self
    }
    
    private func routeToDetail(at page: Int, newsList: [MostViewedResult], searchList: [SearchDoc]) {
        let vc = DetailNewsViewController(page: page, newsList: newsList, newsSearchList: searchList)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func routeToFavorite() {
        let vc = FavoriteViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func loadMoreData() {
        guard !isLoadingData else {
            return // Prevent multiple requests
        }
        
        isLoadingData = true
        currentPage += 1 // Load the next page
        
        viewModel.fetchSearchNews(query: searchText, page: currentPage)
    }
    
    @objc private func updateCollectionViewLayout() {
        let layout = HomeCollectionFlowLayout(isSuggestion: isSearchEmptyState)
        collectionView?.collectionViewLayout = layout
        
        if let layout = collectionView?.collectionViewLayout as? HomeCollectionFlowLayout {
            layout.invalidateLayout()
            collectionView?.reloadData()
        }
    }
    
    @objc private func favoriteButtonTapped() {
        routeToFavorite()
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isSearching {
            return viewModel.newsSearchList.count
        } else if isSearchEmptyState {
            return viewModel.searchSuggestion.count
        } else {
            return viewModel.newsList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsListCollectionViewCell.identifier(), for: indexPath) as? NewsListCollectionViewCell else { return UICollectionViewCell() }
        
        if isSearching {
            let data = viewModel.newsSearchList[indexPath.row]
            
            cell.setupUI(withSearch: data, isImageSmaller: UIDevice.current.orientation.isLandscape)
            
        } else if isSearchEmptyState {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchSuggestionCollectionViewCell.reuseIdentifier, for: indexPath) as? SearchSuggestionCollectionViewCell else { return UICollectionViewCell() }
            
            let suggestion = viewModel.searchSuggestion.reversed()[indexPath.row]
            
            cell.configure(with: suggestion)
            
            return cell
            
        } else {
            let data = viewModel.newsList[indexPath.row]
            
            cell.setupUI(with: data, isImageSmaller: UIDevice.current.orientation.isLandscape)
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if isSearching {
            routeToDetail(at: indexPath.row, newsList: [], searchList: viewModel.newsSearchList)

        } else if isSearchEmptyState, !isSearching {
            let suggestion = viewModel.searchSuggestion.reversed()[indexPath.row]

            searchController.searchBar.text = suggestion
        } else {
            routeToDetail(at: indexPath.row, newsList: viewModel.newsList, searchList: [])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.size.height
        
        if offsetY > contentHeight - screenHeight - 100, isSearching {
            loadMoreData()
        }
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isSearchEmptyState {
            return CGSize(width: collectionView.bounds.width, height: 60)
        } else {
            guard let layout = collectionView.collectionViewLayout as? HomeCollectionFlowLayout else { return CGSize(width: collectionView.bounds.width, height: 120) }
            return layout.itemSize
        }
    }
}

extension HomeViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        if !searchText.isEmpty {
//            isSearching = true
            
        } else {
            isSearching = false
        }
        self.searchText = searchText
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchController.searchBar.text else { return }
        
        if searchText.isEmpty {
            isSearchEmptyState = true
            collectionView?.reloadData()
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        guard let searchText = searchController.searchBar.text else { return true }

        if searchText.isEmpty {
            isSearchEmptyState = true
            collectionView?.reloadData()
        }
        
        return true
    }
        
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchController.searchBar.text else { return }

        if !searchText.isEmpty {
            isSearching = true
            isSearchEmptyState = false
            viewModel.newsSearchList.removeAll()
            viewModel.addSuggestions(text: searchText)
            viewModel.fetchSearchNews(query: searchText, page: currentPage)
            collectionView?.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        isSearchEmptyState = false
        viewModel.newsSearchList.removeAll()
        collectionView?.reloadData()
    }
    
}
