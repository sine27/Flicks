//
//  MoviesViewController.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/2/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource,   UICollectionViewDelegateFlowLayout  {
    
    let helper = HelperFunctions()
    
    // MARK : variables >>>>>
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var refreshButton: UIButton!

    @IBOutlet weak var collectionToSearch: NSLayoutConstraint!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var dropdownView: UIView!
    
    @IBOutlet weak var dropDownImg: UIImageView!

    @IBOutlet weak var recentButton: UIButton!
    
    @IBOutlet weak var popularityButton: UIButton!
    
    @IBOutlet weak var rateButton: UIButton!
    
    // All movies info from database
    var movies: [NSDictionary] = []
    
    // filtered movies info after seach bar activated
    var searchResults : [NSDictionary] = []
    
    // pull to refresh
    let refreshControl = UIRefreshControl()
    
    // tap gesture
    var tapGesture = UITapGestureRecognizer()
    
    // if seach bar is activated
    var searchActive = false
    
    var isDropped = false
    
    // <<<<< variables
    
    // MARK : Dropdown Menu For Sorting
    @IBAction func filterButtonTapped(_ sender: Any) {
        let upimg = UIImage(named: "up")
        if (isDropped) {
            hideDrodown()
            moviesCollectionView.removeGestureRecognizer(tapGesture)
        } else {
            UIView.animate(withDuration: 0.5) {
                self.loadViewIfNeeded()
                self.filterButton.setImage(upimg, for: .normal)
                self.dropdownView.isHidden = false
            }
            isDropped = true
            
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(MoviesViewController.autoHideDropdownWhenTapOutside(sender: )))
            moviesCollectionView.addGestureRecognizer(tapGesture)
        }
    }
    
    func autoHideDropdownWhenTapOutside(sender: UITapGestureRecognizer) {
        hideDrodown()
        moviesCollectionView.removeGestureRecognizer(tapGesture)
    }
    
    func hideDrodown() {
        let downimg = UIImage(named: "down")
        isDropped = false
        UIView.animate(withDuration: 0.5) {
            self.loadViewIfNeeded()
            self.filterButton.setImage(downimg, for: .normal)
            self.dropdownView.isHidden = true
        }
    }
    
    // Sort when key button tapped
    @IBAction func recentTapped(_ sender: Any) {
        filterButton.setTitle("Date ", for: .normal)
        hideDrodown()
        sortKey(byKey: "release_date")
    }

    @IBAction func popularTapped(_ sender: Any) {
        filterButton.setTitle("Popularity ", for: .normal)
        hideDrodown()
        sortKey(byKey: "popularity")
    }
    @IBAction func rateTapped(_ sender: Any) {
        
        filterButton.setTitle("Rate ", for: .normal)
        hideDrodown()
        sortKey(byKey: "vote_average")
    }
    
    // hide navigationBar when searching
    override func viewWillAppear(_ animated: Bool) {
        if searchBar.isHidden == false {
            self.navigationController?.isNavigationBarHidden = true
        } else {
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    // view setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup collection view
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        
        // All subviews : labels and spinner
        helper.subviewSetup(sender: self)
        
        // cunstom navigation bar
        helper.navigationBarSetup(sender : self)
        
        // display activity indicator
        helper.activityIndicator(sender: self)
        
        // setup pull to refresh activity indicator
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: [NSForegroundColorAttributeName: UIColor.init(white: 1, alpha: 1)])
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refresh(sender: )), for: UIControlEvents.valueChanged)
        moviesCollectionView.addSubview(refreshControl)
        
        // setup collection view layout
        helper.collectionViewLayoutSetup(collectionView: self.moviesCollectionView, view : self)
        
        // setup refresh button
        refreshButton.alpha = 0
        self.refreshButton.isUserInteractionEnabled = false
        
        searchBar.isHidden = true

        // hide searchBar when search button not clicked
        collectionToSearch.constant = -44
        
        // dropdown menu setup
        dropDownImg.layer.masksToBounds = true
        dropDownImg.layer.cornerRadius = 10
        dropdownView.isHidden = true
        
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
                let notifyText = "Not Found"
                helper.showNotifyLabelCenter(sender: self, notificationLabel: notifyText, notifyType: 0)
            } else {
                helper.removeNotifyLabelCenter()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "showMovieDetail") {
            let vc = segue.destination as! MovieDetailViewController
            
            if let cell = sender as? UICollectionViewCell {
                if let indexPath = moviesCollectionView.indexPath(for: cell) {
                    var movie : NSDictionary!
                    
                    if (searchActive) {
                        movie = searchResults[indexPath.row]
                    } else {
                        movie = movies[indexPath.row]
                    }
                    vc.movie = movie
                }
            }
        }
    }

    // show footer if needed
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        helper.footerSetup(scrollView: scrollView, collectionView: moviesCollectionView, view: self, label: "No More Results", searchActive: searchActive)
    }
    
    // MARK : search bar controller >>>>>
    
    @IBAction func searchActivated(_ sender: Any) {
        UIView.animate(withDuration: 0.6) {
            self.loadViewIfNeeded()
            self.collectionToSearch.constant = 0
            self.searchBar.isHidden = false
            self.navigationController?.isNavigationBarHidden = true
            self.searchBar.becomeFirstResponder()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        self.moviesCollectionView.reloadData()
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(MoviesViewController.autoHideKeyboardWhenTapOutside(sender: )))
        moviesCollectionView.addGestureRecognizer(tapGesture)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        moviesCollectionView.removeGestureRecognizer(tapGesture)
        
        if searchBar.text == "" {
            searchActive = false
            moviesCollectionView.reloadData()
            
            // show navigationBar and hide searchBar
            UIView.animate(withDuration: 0.6) {
                self.loadViewIfNeeded()
                self.collectionToSearch.constant = -44
                self.searchBar.isHidden = true
                self.navigationController?.isNavigationBarHidden = false
            }
        }
    }
    
    func autoHideKeyboardWhenTapOutside(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        UIView.animate(withDuration: 0.6) {
            self.loadViewIfNeeded()
            self.collectionToSearch.constant = -44
            self.searchBar.isHidden = true
            self.navigationController?.isNavigationBarHidden = false
        }
        searchActive = false;
        searchResults = []
        searchBar.text = ""
        
        searchBar.resignFirstResponder()
        
        helper.removeNotifyLabelCenter()
        
        self.moviesCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
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
        helper.subviewSetup(sender: self)
        helper.activityIndicator(sender: self)
        refresh(sender: self)
    }
    
    // MARK : helper functions >>>>>
    
    func sortKey(byKey : String) {
        
        if byKey == "release_date" {
            sortByDate()
        } else {
            movies.sort {
                item1, item2 in
                let data1 = item1[byKey] as! Double
                let data2 = item2[byKey] as! Double
                return data1 > data2
            }
        }
        moviesCollectionView.reloadData()
    }
    
    func sortByDate () {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        movies.sort {
            item1, item2 in
            let data1 = item1["release_date"] as! String
            let data2 = item2["release_date"] as! String
            let date1 = dateFormatter.date(from: data1)
            let date2 = dateFormatter.date(from: data2)
            return date1! > date2!
        }
    }
    
    // re-send the request
    func refresh(sender:AnyObject) {
        filterButton.setTitle("Filter ", for: .normal)
        request()
    }
    
    // MARK : JSON request >>>
    func request () {
        
        helper.removeNotifyLabelCenter()
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            self.helper.stopActivityIndicator()
            
            if let error = error {
                
                self.searchBar.isUserInteractionEnabled = false
                
                let notifyText = "\(error.localizedDescription)"
                self.helper.showNotifyLabelCenter(sender: self, notificationLabel: notifyText, notifyType: 1)
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.refreshButton.alpha = 1
                })
                self.refreshButton.isUserInteractionEnabled = true
            }
            
            else if let data = data {
                
                self.searchBar.isUserInteractionEnabled = true
                
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    
                    self.movies = dataDictionary["results"] as! [NSDictionary]
                    
                    self.moviesCollectionView.reloadData()
                    
                    self.tabBarController?.tabBar.items?[0].badgeValue = "\(self.movies.count)"
                    
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
        task.resume()
    }
    // <<< JSON request
    
    // <<<<< helper functions
}
