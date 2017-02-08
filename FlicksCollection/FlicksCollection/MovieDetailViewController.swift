//
//  MovieDetailViewController.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/7/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import Cosmos

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var moviePostImg: UIImageView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewToTop: NSLayoutConstraint!
    
    @IBOutlet weak var upButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var voteLabel: UILabel!
    
    @IBOutlet weak var numVoteLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!

    @IBOutlet weak var star: CosmosView!
    
    var movie : NSDictionary = NSDictionary()
    
    var isContentShowed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        print(movie)
        
        self.navigationController?.isNavigationBarHidden = false
        viewToTop.constant = self.view.frame.height - 70
        self.contentView.alpha = 0.2
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
        
        dataSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func upButtonTapped(_ sender: Any) {
        
        let upButtonImg = UIImage(named : "upButton")
        let downButtonImg = UIImage(named : "downButton")

        if (isContentShowed) {
            
            UIView.animate(withDuration: 0.8, animations: {
                self.viewToTop.constant = self.view.frame.height - 70
                self.view.layoutIfNeeded()
                self.contentView.alpha = 0.2
            })
            isContentShowed = false
            upButton.setBackgroundImage(upButtonImg, for: .normal)
            
        } else {
            UIView.animate(withDuration: 0.8, animations: {
                self.viewToTop.constant = self.view.frame.height / 2 - 70
                self.view.layoutIfNeeded()
                self.contentView.alpha = 0.8
            })
            
            isContentShowed = true
            upButton.setBackgroundImage(downButtonImg, for: .normal)
        }
    }
    
    func dataSetup () {
        // assign data
        if let imageUrlString = movie.value(forKeyPath: "poster_path") as? String {
            let newImageUrlString = "https://image.tmdb.org/t/p/w342\(imageUrlString)"
            let imageUrl = URL(string: newImageUrlString)!
            moviePostImg.setImageWith(imageUrl)
        }
        
        titleLabel.text = movie.value(forKey: "original_title") as! String?
        
        let dateString = movie.value(forKey: "release_date") as! String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let myDate = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "MMMM dd, YYYY"
        
        dateLabel.text = dateFormatter.string(from: myDate!)
        
        let vote = movie.value(forKey: "vote_average") as! Double
        
        star.rating = vote / 2
        
        let numVote = movie.value(forKey: "vote_count") as! Int
        
        star.text = "\(vote) (\(numVote)) "
        
        overviewLabel.text = movie.value(forKey: "overview") as! String?

    }
    
}
