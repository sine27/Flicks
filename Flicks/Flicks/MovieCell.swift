//
//  MovieCell.swift
//  Flicks
//
//  Created by Shayin Feng on 2/1/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    
    @IBOutlet weak var movieTitle: UILabel!
    
    @IBOutlet weak var movieDetail: UILabel!
    
    // if img is loaded
    var imgIsLoading = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if (imgIsLoading) {
            self.alpha = 0
            UIView.animate(withDuration: 0.6, animations: {
                self.alpha = 1
                self.imgIsLoading = false
            })
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
