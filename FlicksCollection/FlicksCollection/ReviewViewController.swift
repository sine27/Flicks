//
//  ReviewViewController.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/10/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit

extension String {
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return boundingBox.height
    }
}

class ReviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var reviewsTableView: UITableView!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var errorButton: UIButton!
    
    @IBOutlet weak var errorToTop: NSLayoutConstraint!
    
    let helper = HelperFunctions()
    
    var headerAnimator = HeaderAnimator()
    
    var footerAnimator = FooterAnimator()
    
    var movie : MovieModel!
    
    var isMoreDataLoading = false
    
    var page = 1
    
    var totalPage = 0
    
    var totalResults = 0
    
    var selectRowAt = -1
    
    var previousSelectRowAt = -1
    
    var reviews : [NSDictionary] = []

    @IBAction func errorButtonTapped(_ sender: Any) {
        reviewsTableView.es_startPullToRefresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        
        reviewsTableView.rowHeight = 100
        
        let imageUrlString = movie.poster_path
        
        if imageUrlString != "" {
            let newImageUrlString = "https://image.tmdb.org/t/p/w342\(imageUrlString)"
            let imageUrl = URL(string: newImageUrlString)!
            backgroundImage.setImageWith(imageUrl)
        } else {
            backgroundImage.image = UIImage(named: "noImg")
        }
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect : blurEffect)
        blurView.frame = self.view.bounds
        backgroundImage.addSubview(blurView)
        
        // All subviews : labels and spinner
        helper.subviewSetup(sender: self)
        
        helper.activityIndicator(sender: self)
        
        reviewsTableView.expriedTimeInterval = 10.0
        reviewsTableView.es_autoPullToRefresh()
        
        /// Custom refreshController
        self.reviewsTableView.es_addPullToRefresh(animator: headerAnimator) {
            self.page = 1
            self.request()
        }
        
        self.reviewsTableView.es_addInfiniteScrolling(animator: footerAnimator) {
            
            self.isMoreDataLoading = true
            self.request()
        }

        request()
        
        print(reviews)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    // retrun data for each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = reviewsTableView.dequeueReusableCell(withIdentifier: "reviewCell") as! ReviewTableViewCell
        
        let review = reviews[indexPath.row]
        
        cell.authorLabel.text = review.value(forKey: "author") as? String ?? ""
        cell.contentLabel.text = review.value(forKey: "content") as? String ?? ""
        
        cell.alpha = 0
        UIView.animate(withDuration: 1, animations: { cell.alpha = 1 })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectRowAt = indexPath.row
        reviewsTableView.beginUpdates()
        reviewsTableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let contentString = reviews[indexPath.row].value(forKey: "content") as? String ?? "No content"
        let contentHeight = contentString.heightWithConstrainedWidth(width: reviewsTableView.frame.width - 10, font: .systemFont(ofSize: 15.0, weight: UIFontWeightThin))

        if contentHeight < 60 {
            return contentHeight + 60
        }
        else if indexPath.row == selectRowAt {
            if previousSelectRowAt == selectRowAt {
                previousSelectRowAt = -1
                return 100.0
            }
            previousSelectRowAt = selectRowAt
            return contentHeight + 60
        }
        return 100.0
    }
    
    // url request for data
    func request () {
        
        UIView.animate(withDuration: 1.0, animations: {
            self.errorButton.isHidden = true
        })
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(movie.id)/reviews?api_key=\(apiKey)&page=\(page)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            self.helper.stopActivityIndicator()
            
            if let error = error {
                NSLog("Review Loading [Fail] \(error.localizedDescription)")
                
                /// stop loading more data
                if self.isMoreDataLoading {
                    self.errorToTop.constant = self.view.frame.height - 158
                    self.errorButton.setTitle("Network Error! Pull to Load", for: .normal)
                    UIView.animate(withDuration: 0.8, animations: {
                        self.loadViewIfNeeded()
                        self.errorButton.isHidden = false
                    })
                    self.reviewsTableView.es_stopLoadingMore()
                }
                else {
                    self.errorToTop.constant = 0
                    self.errorButton.setTitle("Network Error! Pull to Refresh", for: .normal)
                    UIView.animate(withDuration: 0.8, animations: {
                        self.errorButton.isHidden = false
                    })
                    self.reviewsTableView.es_stopPullToRefresh()
                }
                
                if self.reviews.count != 0 {
                    self.errorButton.isUserInteractionEnabled = false
                } else {
                    self.errorButton.setTitle("Network Error! Tap to Refresh", for: .normal)
                }

            }
            
            else if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    
                    self.totalPage = dataDictionary["total_pages"] as! Int
                    
                    self.totalResults = dataDictionary["total_results"] as! Int
                    
                    if (self.totalPage <= 1) {
                        self.reviewsTableView.es_removeRefreshFooter()
                        self.isMoreDataLoading = false
                    }
                    
                    if self.totalResults > 0 {
                        self.navigationItem.title = "Reviews (\(self.totalResults))"
                    }
                    
                    if self.isMoreDataLoading {
                        
                        NSLog("Review Loading [Success] page\(self.page)")
                        
                        if ( dataDictionary["results"] as! [NSDictionary] ) == [] {
                            // If no more data
                            self.reviewsTableView.es_noticeNoMoreData()
                            
                        } else {
                            self.reviews += dataDictionary["results"] as! [NSDictionary]
                            
                            // If common end
                            self.reviewsTableView.es_stopLoadingMore()
                            
                            self.reviewsTableView.reloadData()
                        }
                    }
                    
                    else {
                        
                        NSLog("Review Loading [Success] refresh : page\(self.page)")
                        
                        self.reviews = dataDictionary["results"] as! [NSDictionary]
                        
                        if self.reviews.count == 0 {
                            self.helper.showNotifyLabelCenter(sender: self, notificationLabel: "No Comment", notifyType: 0)
                        }
                        
                        // Set ignore footer or not
                        self.reviewsTableView.es_stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
                        
                        self.reviewsTableView.reloadData()
                    }
                }
                self.page += 1
            }
            self.isMoreDataLoading = false
        }
        task.resume()
    }
}
