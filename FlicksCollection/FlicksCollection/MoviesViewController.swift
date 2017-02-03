//
//  MoviesViewController.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/2/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource,   UICollectionViewDelegateFlowLayout {
    
    let helper = HelperFunctions()
    
// MARK : variables >>>>>
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!

    @IBOutlet weak var refreshButton: UIButton!
    
    // All movies info from database
    var movies: [NSDictionary] = []
    
    // filtered movies info after seach bar activated
    var searchResults : [NSDictionary] = []
    
    // pull to refresh
    let refreshControl = UIRefreshControl()
    
    // if seach bar is activated
    var searchActive = false
    
    let notifyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
    
    let footerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
// <<<<< variables
    
    // hide keyboard by gesture
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
// MARK : helper functions
    // re-send the request
    func refresh(sender:AnyObject) {
        request()
    }
    
    // MARK : JSON request >>>>>
    func request () {
        
        notifyLabel.alpha = 0
        notifyLabel.removeFromSuperview()
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                print(">>>>>> [URLDataTask completion]: \(error.localizedDescription)")
                self.helper.stopActivityIndicator()
                self.notifyLabel.text = "\(error.localizedDescription)"
                self.notifyLabel.alpha = 1
                self.notifyLabel.numberOfLines = 2
                self.view.addSubview(self.notifyLabel)
                sleep(5)
                UIView.animate(withDuration: 0.5, animations: {
                    self.notifyLabel.center.y = self.notifyLabel.center.y - 70
                })
                UIView.animate(withDuration: 0.5, animations: {
                    self.refreshButton.alpha = 1
                    self.refreshButton.isUserInteractionEnabled = true
                })
                
            }
            
           else if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    
                    self.moviesCollectionView.reloadData()
                    self.helper.stopActivityIndicator()
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
        task.resume()
    }
    // <<<<< JSON request
    
// <<<<< helper functions

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display activity indicator
        helper.activityIndicator(sender: self)
        
        // setup pull to refresh activity indicator
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: [NSForegroundColorAttributeName: UIColor.init(white: 1, alpha: 1)])

        refreshControl.addTarget(self, action: #selector(MoviesViewController.refresh(sender: )), for: UIControlEvents.valueChanged)
        moviesCollectionView.addSubview(refreshControl)
        
        // setup
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        
        let layout = self.moviesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let itemWidth = self.view.frame.width / 2
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: itemWidth, height: (1.5 * itemWidth))
        
        notifyLabel.numberOfLines = 1
        notifyLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
        notifyLabel.font = UIFont(name:"HelveticaNeue;", size: 30.0)
        notifyLabel.textAlignment = NSTextAlignment.center
        notifyLabel.center = self.view.center
        notifyLabel.contentMode = UIViewContentMode.scaleAspectFit
        notifyLabel.alpha = 0
        
        refreshButton.alpha = 0
        self.refreshButton.isUserInteractionEnabled = false
        
        // requst for data
        request()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(searchActive) {
            if searchResults.count == 0 && searchBar.text != "" {
                notifyLabel.text = "Not Found"
                self.notifyLabel.center.y = self.notifyLabel.center.y
                notifyLabel.alpha = 1
                self.view.addSubview(notifyLabel)
            } else {
                notifyLabel.alpha = 0
                notifyLabel.removeFromSuperview()
            }
            return searchResults.count
        }
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Access
        let cell = moviesCollectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCollectionViewCell

        cell.layer.borderWidth = 0
        
        if refreshControl.isRefreshing {
            cell.imgIsLoading = true
        }
        
        var movie : NSDictionary
        
        // check if searching
        if(searchActive){
            movie = searchResults[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
        
        // assign data
        if let imageUrlString = movie.value(forKeyPath: "poster_path") as? String {
            let newImageUrlString = "https://image.tmdb.org/t/p/w342\(imageUrlString)"
            let imageUrl = URL(string: newImageUrlString)!
            cell.movieImage.setImageWith(imageUrl)
        }
        
        cell.fadeInImg()
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        footerLabel.numberOfLines = 1
        footerLabel.textColor = UIColor.init(white: 1, alpha: 0.6)
        footerLabel.font = UIFont(name:"HelveticaNeue;", size: 30.0)
        footerLabel.text = "No More Results"
        footerLabel.textAlignment = NSTextAlignment.center
        footerLabel.contentMode = UIViewContentMode.scaleAspectFit
        footerLabel.alpha = 0
        
        if ((scrollView.contentOffset.y + scrollView.frame.size.height - 50) >= scrollView.contentSize.height) && !searchActive
        {

            let footerHeight = scrollView.contentOffset.y + scrollView.frame.size.height - scrollView.contentSize.height
            
            footerLabel.center.y = self.moviesCollectionView.frame.maxY - (footerHeight / 2)
            footerLabel.center.x = self.view.center.x

            footerLabel.alpha = 1
            self.view.addSubview(footerLabel)
        } else {
            
            UIView.animate(withDuration: 0.5, animations: {
                self.footerLabel.alpha = 0
            })
            self.view.willRemoveSubview(footerLabel)
        }
    }
    
// MARK : search bar controller >>>>>
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        self.moviesCollectionView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchResults = []
        searchBar.text = ""
        searchBar.resignFirstResponder()
        notifyLabel.alpha = 0
        notifyLabel.removeFromSuperview()
        self.moviesCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // reset search result
        searchResults = []
        
        // search filter
        for movie in movies {
            let title: String = movie.value(forKey: "title") as! String
            let overview: String = movie.value(forKey: "overview") as! String
            if title.range(of: searchText, options: NSString.CompareOptions.caseInsensitive) != nil {
                searchResults.append(movie)
            } else if overview.range(of: searchText, options: NSString.CompareOptions.caseInsensitive) != nil {
                searchResults.append(movie)
            }
        }
        
        // reload data for search
        searchActive = true;
        self.moviesCollectionView.reloadData()
    }
// <<<<< search bar controller

    @IBAction func refreshWhenErrorOccur(_ sender: Any) {
        
        self.refreshButton.alpha = 0
        self.refreshButton.isUserInteractionEnabled = true
        notifyLabel.center.y = self.view.center.y
        helper.activityIndicator(sender: self)
        refresh(sender: self)
    }


}
