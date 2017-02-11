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
    
    var movie : MovieModel!
    
    // tap gesture
    var tapGesture = UITapGestureRecognizer()
    
    var isContentShowed = false
    
    var imgLoadSuccessful = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        // hide content view at first
        viewToBottom.constant = 0 - self.contentView.frame.height + 15
    }
    
    override func viewDidAppear(_ animated: Bool) {
        showView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(movie)
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.imgScrollView.minimumZoomScale = 1.0
        self.imgScrollView.maximumZoomScale = 6.0
        
        self.contentView.alpha = 0.2
        moviePostImg.alpha = 0.6
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
        
        self.automaticallyAdjustsScrollViewInsets = false
        imgScrollView.isUserInteractionEnabled = false
        
        moviePostImg.image = UIImage(named: "noImg")
        
        dataSetup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func upButtonTapped(_ sender: Any) {
        
        if imgLoadSuccessful {
            imgScrollView.isUserInteractionEnabled = !(imgScrollView.isUserInteractionEnabled)
        }
        // hide content view
        if (isContentShowed) {
            hideView()
        }
            // show content view
        else {
            showView()
        }
    }
    
    // hide content view
    func hideView () {
        let upButtonImg = UIImage(named : "upButton")
        
        UIView.animate(withDuration: 1.0, animations: {
            self.moviePostImg.alpha = 1
            self.viewToBottom.constant = 0 - self.contentView.frame.height + 5
            self.view.layoutIfNeeded()
            self.contentView.alpha = 0.2
            self.upButton.setBackgroundImage(upButtonImg, for: .normal)
        })
        
        isContentShowed = false
        imgScrollView.isUserInteractionEnabled = true
        moviePostImg.removeGestureRecognizer(tapGesture)
    }
    
    // show content view
    func showView () {
        let downButtonImg = UIImage(named : "downButton")
        
        UIView.animate(withDuration: 1.0, animations: {
            self.moviePostImg.alpha = 0.6
            self.viewToBottom.constant = 5
            self.view.layoutIfNeeded()
            self.contentView.alpha = 0.75
            self.upButton.setBackgroundImage(downButtonImg, for: .normal)
        })
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(MovieDetailViewController.autoHideViewWhenTapOutside(sender: )))
        self.view.addGestureRecognizer(tapGesture)
        
        isContentShowed = true
    }
    
    func autoHideViewWhenTapOutside(sender: UITapGestureRecognizer) {
        hideView()
    }
    
    func dataSetup () {
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect : blurEffect)
        blurView.frame = moviePostImg.bounds
        moviePostImg.addSubview(blurView)
        
        // assign data
        
        let imageUrlString = movie.poster_path
        
        if imageUrlString != "" {
            let newImageUrlString = "https://image.tmdb.org/t/p/w342\(imageUrlString)"
            
            let imageUrl = URL(string: newImageUrlString)!
            
            let newImageUrlStringOrg = "https://image.tmdb.org/t/p/original\(imageUrlString)"
            
            let imageUrlOrg = URL(string: newImageUrlStringOrg)!
            
            let smallImageRequest = URLRequest(url: imageUrl)
            
            let largeImageRequest = URLRequest(url: imageUrlOrg)
            
            let defaultImage = UIImage(named: "noImg")
            
            moviePostImg.setImageWith(smallImageRequest, placeholderImage: defaultImage, success: { (smallImageRequest, smallImageResponse, smallImage) in
                self.moviePostImg.alpha = 0.0
                self.moviePostImg.image = smallImage;
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    
                    if self.isContentShowed {
                        self.moviePostImg.alpha = 0.6
                    } else {
                        self.moviePostImg.alpha = 1.0
                    }
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
        
        titleLabel.text = movie.original_title
        
        let dateString = movie.release_date
        
        if dateString == "" {
            dateLabel.text = "Undefined"
        }
        else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let myDate = dateFormatter.date(from: dateString)
            dateFormatter.dateFormat = "MMMM dd, YYYY"
            
            dateLabel.text = dateFormatter.string(from: myDate!)
        }
        
        let vote = movie.vote_average
        
        star.rating = vote / 2
        
        let numVote = movie.vote_count
        
        star.text = "\(vote) (\(numVote)) "
        
        overviewLabel.text = movie.overview
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.moviePostImg
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showReviews") {
            let vc = segue.destination as! ReviewViewController
            vc.movie = self.movie
        }
    }
    
}
