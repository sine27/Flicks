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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
