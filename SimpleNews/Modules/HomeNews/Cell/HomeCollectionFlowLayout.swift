//
//  HomeCollectionFlowLayout.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import UIKit

class HomeCollectionFlowLayout: UICollectionViewFlowLayout {
    
    let isSuggestion: Bool
    
    init(isSuggestion: Bool) {
        self.isSuggestion = isSuggestion
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        setupLayout()
    }
    
    private func setupLayout() {
        let columns: CGFloat = UIDevice.current.orientation.isLandscape ? 4 : 1
        let spacing: CGFloat = 8
        
        let availableWidth = collectionView?.bounds.width ?? 0
        let totalSpacing = spacing * (columns - 1)
        let itemWidth = (availableWidth - totalSpacing) / columns
        
        itemSize = CGSize(width: itemWidth, height: 120)
        minimumLineSpacing = spacing
        minimumInteritemSpacing = spacing
    }
}
