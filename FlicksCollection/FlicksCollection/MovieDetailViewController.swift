//
//  MovieDetailViewController.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/7/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import Cosmos

class MovieDetailViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var moviePostImg: UIImageView!
    
    @IBOutlet weak var imgScrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var upButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var overviewLabel: UILabel!

    @IBOutlet weak var star: CosmosView!
    
    @IBOutlet weak var viewToBottom: NSLayoutConstraint!
    
    var movie : NSDictionary = NSDictionary()
    
    var isContentShowed = true
    
    var imgLoadSuccessful = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(movie)
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.imgScrollView.minimumZoomScale = 1.0
        self.imgScrollView.maximumZoomScale = 6.0
        
        viewToBottom.constant = 5
        self.contentView.alpha = 0.8
        moviePostImg.alpha = 0.6
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
        
        self.automaticallyAdjustsScrollViewInsets = false
        imgScrollView.isUserInteractionEnabled = false
        
        dataSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func upButtonTapped(_ sender: Any) {
        
        let upButtonImg = UIImage(named : "upButton")
        let downButtonImg = UIImage(named : "downButton")
        
        if imgLoadSuccessful {
            imgScrollView.isUserInteractionEnabled = !(imgScrollView.isUserInteractionEnabled)
        }

        if (isContentShowed) {
            
            UIView.animate(withDuration: 0.8, animations: {
                self.moviePostImg.alpha = 1
                self.viewToBottom.constant = 0 - self.contentView.frame.height + 10
                self.view.layoutIfNeeded()
                self.contentView.alpha = 0.2
            })

            upButton.setBackgroundImage(upButtonImg, for: .normal)
            
        } else {
            UIView.animate(withDuration: 0.8, animations: {
                self.moviePostImg.alpha = 0.6
                self.viewToBottom.constant = 5
                self.view.layoutIfNeeded()
                self.contentView.alpha = 0.8
            })
            
            upButton.setBackgroundImage(downButtonImg, for: .normal)
        }
        isContentShowed = !isContentShowed
    }
    
    func dataSetup () {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect : blurEffect)
        blurView.frame = moviePostImg.bounds
        moviePostImg.addSubview(blurView)
        
        // assign data
        if let imageUrlString = movie.value(forKeyPath: "poster_path") as? String {
            let newImageUrlString = "https://image.tmdb.org/t/p/w342\(imageUrlString)"
            
            let imageUrl = URL(string: newImageUrlString)!
            
            let newImageUrlStringOrg = "https://image.tmdb.org/t/p/original\(imageUrlString)"
            
            let imageUrlOrg = URL(string: newImageUrlStringOrg)!

            let smallImageRequest = URLRequest(url: imageUrl)
            
            let largeImageRequest = URLRequest(url: imageUrlOrg)

            moviePostImg.setImageWith(smallImageRequest, placeholderImage: nil, success: { (smallImageRequest, smallImageResponse, smallImage) in
                self.moviePostImg.alpha = 0.0
                self.moviePostImg.image = smallImage;
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.moviePostImg.alpha = 1.0
                }, completion: { (sucess) -> Void in
                    self.moviePostImg.setImageWith(
                        largeImageRequest,
                        placeholderImage: smallImage,
                        success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                            self.moviePostImg.image = largeImage;
                            self.imgLoadSuccessful = true
                            // fade out blur view
                            UIView.animate(withDuration: 1.0, animations: {
                                blurView.alpha = 0
                            }, completion: { (finished: Bool) -> Void in
                                blurView.removeFromSuperview()
                            })
                        },
                        failure: { (request, response, error) -> Void in
                            let defaultImg = UIImage(named: "background")
                            self.moviePostImg.image = defaultImg
                    })
                })
            }, failure: {(request, response, error) in
                let defaultImg = UIImage(named: "background")
                self.moviePostImg.image = defaultImg
            })
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
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.moviePostImg
    }
    
}
