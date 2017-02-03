//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Shayin Feng on 2/1/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var moviesTableView: UITableView!
    
    @IBOutlet weak var mySearchBar: UISearchBar!
    
    // All movies info from database
    var movies: [NSDictionary] = []
    
    // filtered movies info after seach bar activated
    var searchResults : [NSDictionary] = []
    
    // pull to refresh
    let refreshControl = UIRefreshControl()
    
    // if seach bar is activated
    var searchActive = false
    
    // MARK : Activity indicator >>>>>
    fileprivate var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    fileprivate var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    func activityIndicator() {
        
        blur.frame = CGRect(x: 30, y: 30, width: 80, height: 80)
        blur.layer.cornerRadius = 10
        blur.center = self.view.center
        blur.clipsToBounds = true
        blur.alpha = 0
        
        spinner.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        spinner.isHidden = false
        spinner.center = self.view.center
        spinner.startAnimating()
        spinner.alpha = 0
        
        self.view.addSubview(blur)
        self.view.addSubview(spinner)
        
        UIView.animate(withDuration: 0.6, animations: {
            self.blur.alpha = 1
            self.spinner.alpha = 1
        })
    }
    
    func stopActivityIndicator() {
        spinner.stopAnimating()
        UIView.animate(withDuration: 0.4, animations: {
            self.blur.alpha = 0
            self.spinner.alpha = 0
        })
        spinner.removeFromSuperview()
        blur.removeFromSuperview()
    }
    
    // <<<<<< Activity indicator
    
    // re-send the request
    func refresh(sender:AnyObject) {
        request()
    }
    
    // hide keyboard by gesture
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    // url request for data
    func request () {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {

                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    
                    self.moviesTableView.reloadData()
                    self.stopActivityIndicator()
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
        task.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // display activity indicator
        activityIndicator()
        
        // setup pull to refresh activity indicator
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refresh(sender: )), for: UIControlEvents.valueChanged)
        moviesTableView.addSubview(refreshControl)

        // tableview setup
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        moviesTableView.rowHeight = 240

        // requst for data
        request()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // return number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return searchResults.count
        }
        return movies.count
    }
    
    // retrun data for each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell
        
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
            let title = movie.value(forKeyPath: "title") as? String
            cell.movieTitle.text = title
            
            cell.movieTitle.text = title

            let detail = movie.value(forKeyPath: "overview") as! String
            cell.movieDetail.text = detail
        }
        return cell
    }
    
    // MARK : search bar controller >>>>>
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        self.moviesTableView.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        mySearchBar.text = ""
        mySearchBar.resignFirstResponder()
        self.moviesTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        mySearchBar.resignFirstResponder()
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // reset search result
        searchResults = []
        
        // search filter
        for movie in movies {
            let title: String = movie.value(forKey: "title") as! String
            if title.range(of: searchText, options: NSString.CompareOptions.caseInsensitive) != nil {
                searchResults.append(movie)
            }
        }
        
        // reload data for search
        searchActive = true;
        self.moviesTableView.reloadData()
    }
    // <<<<< search bar controller
    

}
