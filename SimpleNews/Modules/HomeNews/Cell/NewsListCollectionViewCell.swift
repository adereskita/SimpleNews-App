//
//  NewsListCollectionViewCell.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import UIKit

class NewsListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var snippetsLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI(with data: MostViewedResult, isImageSmaller: Bool) {
        imageWidthConstraint?.constant = isImageSmaller ? 50 : 110

        titleLabel?.text = data.title
        dateLabel?.text = data.publishedDate?.convertToDateFormat()
        snippetsLabel?.text = data.abstract
        
        let url = data.media?.first?.mediaMetadata?.first { $0.format == "mediumThreeByTwo440" }?.url
        
        if let imageUrl = URL(string: url ?? "") {
            ImageDownloader.downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if let image = image {
                        self.imageView?.image = image
                    } else {
                        guard let image = ImageDownloader.getCachedImage(withURL: imageUrl.absoluteString) else
                        {
                            self.imageView?.image = UIImage(systemName: "photo.on.rectangle.fill")
                            return
                        }
                        self.imageView?.image = image
                    }
                }
            }
        }
        
        imageView?.layer.cornerRadius = 8
        self.setNeedsLayout()
    }

    
    func setupUI(withSearch data: SearchDoc, isImageSmaller: Bool) {
        imageWidthConstraint?.constant = isImageSmaller ? 50 : 110
        
        titleLabel?.text = data.headline?.main
        dateLabel?.text = data.pubDate?.convertFromISO8601Format() ?? ""
        snippetsLabel?.text = data.snippet
        
        let url = data.multimedia?.first { $0.subtype == "mediumThreeByTwo440" }?.url
        
        if let imageUrl = URL(string: url ?? "") {
            ImageDownloader.downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if let image = image {
                        self.imageView?.image = image
                    } else {
                        self.imageView?.image = UIImage(systemName: "photo.on.rectangle.fill")
                    }
                }
            }
        }
        
        imageView?.layer.cornerRadius = 8
        self.setNeedsLayout()
    }
    
    func setupUI(withFavorites data: Favorites, isImageSmaller: Bool) {
        imageWidthConstraint?.constant = isImageSmaller ? 50 : 110
        
        titleLabel?.text = data.title
        dateLabel?.text = data.date
        snippetsLabel?.text = data.snippets
        
        let url = data.image
        
        if let imageUrl = URL(string: url ?? "") {
            ImageDownloader.downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if let image = image {
                        self.imageView?.image = image
                    } else {
                        self.imageView?.image = UIImage(systemName: "photo.on.rectangle.fill")
                    }
                }
            }
        }
        
        imageView?.layer.cornerRadius = 8
        self.setNeedsLayout()
    }
}
