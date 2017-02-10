//
//  MovieCollectionViewCell.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/2/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var movieImage: UIImageView!
    
    var movie = NSDictionary()
    
    var imgIsLoading = true
    
    func loadImage() {
        
        // assign data
        if let imageUrlString = movie.value(forKeyPath: "poster_path") as? String {
            
            let newImageUrlString = "https://image.tmdb.org/t/p/w342\(imageUrlString)"
            let imageUrl = URL(string: newImageUrlString)!
            
            let smallImageRequest = URLRequest(url: imageUrl)
            
            let defaultImage = UIImage(named: "noImg")
            
            movieImage.setImageWith(smallImageRequest, placeholderImage: nil, success: { (smallImageRequest, smallImageResponse, smallImage) in
                self.movieImage.alpha = 0.0
                self.movieImage.image = smallImage;
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.movieImage.alpha = 1.0
                })
            }, failure: {(request, response, error) in
                self.movieImage.alpha = 0.0
                self.movieImage.image = defaultImage
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.movieImage.alpha = 1.0
                })
            })
        }
    }
}
