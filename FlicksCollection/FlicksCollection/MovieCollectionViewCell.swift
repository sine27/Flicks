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

    var imgIsLoading = true
    
    func fadeInImg() {
        if (imgIsLoading) {
            self.alpha = 0
            UIView.animate(withDuration: 0.6, animations: {
                self.alpha = 1
                self.imgIsLoading = false
            })
        }
    }
}
