//
//  ImageDownloader.swift
//  SimpleNews
//
//  Created by Ade on 9/1/23.
//

import UIKit

class ImageDownloader {
    static func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        
        /// check if host is already available or not
        var imageURL = url
        if imageURL.host == nil, let baseURL = URL(string: "https://static01.nyt.com/") {
            imageURL = baseURL.appendingPathComponent(url.path)
        }
        
        URLSession.shared.dataTask(with: imageURL) { data, _, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentsDirectory.appendingPathComponent(url.absoluteString)
                    do {
                        try data.write(to: fileURL)
                    } catch {
                        print("Error saving image: \(error)")
                    }
                }
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
    static func getCachedImage(withURL url: String) -> UIImage? {
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(url)
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }

}
