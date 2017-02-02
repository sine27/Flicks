//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Shayin Feng on 2/1/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var moviesTableView: UITableView!
    
    var movies: [NSDictionary] = []
    
    let refreshControl = UIRefreshControl()
    
    // MARK : Activity indicator >>>>>
    fileprivate var blur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
    fileprivate var spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    func activityIndicator() {
        
        blur.frame = CGRect(x: 30, y: 30, width: 80, height: 80)
        blur.layer.cornerRadius = 10
        blur.center = self.view.center
        blur.clipsToBounds = true
        
        spinner.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        spinner.isHidden = false
        spinner.center = self.view.center
        spinner.startAnimating()
        
        self.view.addSubview(blur)
        self.view.addSubview(spinner)
    }
    
    func stopActivityIndicator() {
        spinner.stopAnimating()
        spinner.removeFromSuperview()
        blur.removeFromSuperview()
    }
    
    func refresh(sender:AnyObject) {
        request()
    }
    
    func request () {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            if let data = data {
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    // print(dataDictionary)
                    
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
        
        activityIndicator()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refresh(sender: )), for: UIControlEvents.valueChanged)
        moviesTableView.addSubview(refreshControl)

        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        moviesTableView.rowHeight = 240

        // Do any additional setup after loading the view.
        
        request()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell") as! MovieCell

        let movie = movies[indexPath.row]
        
        // let timestamp = movie["timestamp"] as? String
        if let imageUrlString = movie.value(forKeyPath: "poster_path") as? String {
            let newImageUrlString = "https://image.tmdb.org/t/p/w342\(imageUrlString)"
            let imageUrl = URL(string: newImageUrlString)!
            cell.movieImage.setImageWith(imageUrl)
            // print(movie)
            let title = movie.value(forKeyPath: "title") as? String
            cell.movieTitle.text = title
            
            cell.movieTitle.text = title

            let detail = movie.value(forKeyPath: "overview") as! String
            cell.movieDetail.text = detail
        }
        
        return cell
    }

}
