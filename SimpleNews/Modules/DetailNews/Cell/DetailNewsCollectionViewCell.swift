//
//  DetailNewsCollectionViewCell.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import UIKit

class DetailNewsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cardBackground: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.cardBackground.backgroundColor = .white
        self.cardBackground.layer.cornerRadius = 8
    }
    
    func setupUI(with data: MostViewedResult) {
        titleLabel?.text = data.title
        infoLabel?.text = data.publishedDate?.convertToDateFormat()
        descriptionLabel?.text = data.abstract
        
        let url = data.media?.first?.mediaMetadata?.first { $0.format == "mediumThreeByTwo440" }?.url
        
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
    }

    
    func setupUI(withSearch data: SearchDoc) {
        titleLabel?.text = data.headline?.main
        infoLabel?.text = data.pubDate?.convertFromISO8601Format() ?? ""
        descriptionLabel?.text = data.snippet
        
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
    }

}
