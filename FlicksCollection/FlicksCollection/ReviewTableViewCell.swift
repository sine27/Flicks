//
//  ReviewTableViewCell.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/10/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    let highlightColor = UIColor(red: 1, green: 149/255, blue: 0, alpha: 1)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10
        
        self.layer.backgroundColor = UIColor.clear.cgColor
        
        authorLabel.textColor = highlightColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
