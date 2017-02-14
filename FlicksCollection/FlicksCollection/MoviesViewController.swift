//
//  MoviesViewController.swift
//  FlicksCollection
//
//  Created by Shayin Feng on 2/2/17.
//  Copyright © 2017 Shayin Feng. All rights reserved.
//

import UIKit
import AFNetworking
import ESPullToRefresh

class MoviesViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let helper = HelperFunctions()
    
    // MARK : variables >>>>>
    @IBOutlet weak var moviesCollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var collectionToSearch: NSLayoutConstraint!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var dropdownView: UIView!
    
    @IBOutlet weak var dropDownImg: UIImageView!
    
    @IBOutlet weak var recentButton: UIButton!
    
    @IBOutlet weak var nowPlayingButton: UIButton!
    
    @IBOutlet weak var popularityButton: UIButton!
    
    @IBOutlet weak var rateButton: UIButton!
    
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
    @IBOutlet weak var errorButton: UIButton!
    
    @IBOutlet weak var errorToTop: NSLayoutConstraint!
    
    
    // All movies info from database
    var movies: [NSDictionary] = []
    
    // filtered movies info after seach bar activated
    var searchResults : [NSDictionary] = []

    // tap gesture
    var tapGesture = UITapGestureRecognizer()
    
    var headerAnimator = HeaderAnimator()
    
    var footerAnimator = FooterAnimator()
    
    // if seach bar is activated
    var searchActive = false
    
    var isSorting = false
    
    // dropdown menu dropped
    var isDropped = false
    
    // loading page > 1
    var isMoreDataLoading = false
    
    // page number for request +1 when request data successfully
    var moviePage = 1
    
    var searchPage = 1
    
    var sortPage = 1
    
    // orange color
    let highlightColor = UIColor(red: 1, green: 149/255, blue: 0, alpha: 1)
    
    var endpoint = ""
    
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    
    var requestPrefix = "https://api.themoviedb.org/3"
    
    var movieRequest = ""
    
    var searchRequest = ""
    
    var sortRequest = ""
    
    // <<<<< variables
    @IBAction func errorButtonTapped(_ sender: Any) {
        moviesCollectionView.es_startPullToRefresh()
    }
    
    // MARK : Dropdown Menu For Sorting
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        let crossButtonImage = UIImage(named: "crossButtonImg")
        
        if (isDropped) {
            hideDrodown()
            moviesCollectionView.removeGestureRecognizer(tapGesture)
        }
        else {
            UIView.animate(withDuration: 1.0, animations: {
                self.menuBarButton.image = crossButtonImage
            })
            
            dropdownView.isHidden = false
            isDropped = true
            
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(MoviesViewController.autoHideDropdownWhenTapOutside(sender: )))
            moviesCollectionView.addGestureRecognizer(tapGesture)
        }
    }
    
    func autoHideDropdownWhenTapOutside(sender: UITapGestureRecognizer) {
        hideDrodown()
    }
    
    func hideDrodown() {
        moviesCollectionView.removeGestureRecognizer(tapGesture)
        let menuButtonImage = UIImage(named: "menuButtonImg")
        isDropped = false
        UIView.animate(withDuration: 0.5) {
            self.loadViewIfNeeded()
            self.menuBarButton.image = menuButtonImage
            self.dropdownView.isHidden = true
        }
    }
    
    // Sort when key button tapped
    @IBAction func recentTapped(_ sender: UIButton) {
        resetFilterButtonColor()
        sender.setTitleColor(highlightColor, for: .normal)
        filterButton.setTitle("Date", for: .normal)
        hideDrodown()
        isSorting = true
        sortRequest = "\(requestPrefix)/discover/movie?api_key=\(apiKey)&sort_by=release_date.desc"
        moviesCollectionView.es_startPullToRefresh()
    }
    
    @IBAction func popularTapped(_ sender: UIButton) {
        resetFilterButtonColor()
        sender.setTitleColor(highlightColor, for: .normal)
        filterButton.setTitle("Popularity", for: .normal)
        isSorting = true
        hideDrodown()
        sortRequest = "\(requestPrefix)/discover/movie?api_key=\(apiKey)&sort_by=popularity.desc"
        moviesCollectionView.es_startPullToRefresh()
    }
    @IBAction func rateTapped(_ sender: UIButton) {
        resetFilterButtonColor()
        sender.setTitleColor(highlightColor, for: .normal)
        filterButton.setTitle("Rate", for: .normal)
        hideDrodown()
        isSorting = true
        sortRequest = "\(requestPrefix)/discover/movie?api_key=\(apiKey)&sort_by=vote_average.desc"
        moviesCollectionView.es_startPullToRefresh()
    }
    
    @IBAction func nowPlayingTapped(_ sender: UIButton) {
        resetFilterButtonColor()
        sender.setTitleColor(highlightColor, for: .normal)
        if endpoint == "top_rated" {
            filterButton.setTitle("Top Rated", for: .normal)
        } else {
            filterButton.setTitle("Now Playing", for: .normal)
        }
        hideDrodown()
        isSorting = false
        moviesCollectionView.es_startPullToRefresh()
    }
    
    func resetFilterButtonColor () {
        rateButton.setTitleColor(.white, for: .normal)
        recentButton.setTitleColor(.white, for: .normal)
        popularityButton.setTitleColor(.white, for: .normal)
        nowPlayingButton.setTitleColor(.white, for: .normal)
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
        
        movieRequest = "\(requestPrefix)/movie/\(endpoint)?api_key=\(apiKey)"
        
        // setup collection view
        moviesCollectionView.delegate = self
        moviesCollectionView.dataSource = self
        
        if endpoint == "top_rated" {
            nowPlayingButton.setTitle("Top Rated", for: .normal)
        } else {
            nowPlayingButton.setTitle("Now Playing", for: .normal)
        }

        // All subviews : labels and spinner
        helper.subviewSetup(sender: self)
        
        // cunstom navigation bar
        helper.navigationBarSetup(sender : self)
        
        // display activity indicator
        helper.activityIndicator(sender: self)
        
        // setup collection view layout
        helper.collectionViewLayoutSetup(collectionView: self.moviesCollectionView, view : self)
        
        searchBar.isHidden = true
        
        // error button
        errorButton.isHidden = true
        
        // hide searchBar when search button not clicked
        collectionToSearch.constant = -44
        
        // dropdown menu setup
        dropDownImg.layer.masksToBounds = true
        dropDownImg.layer.cornerRadius = 10
        dropdownView.isHidden = true
        
        nowPlayingButton.setTitleColor(highlightColor, for: .normal)
        
        moviesCollectionView.expriedTimeInterval = 10.0
        
        /// Custom refreshController
        self.moviesCollectionView.es_addPullToRefresh(animator: headerAnimator) {
            
            if self.searchActive && self.searchRequest != "" {
                self.searchPage = 1
                self.request(identity: 0, urlString: self.searchRequest)
            }
            else if self.isSorting {
                self.sortPage = 1
                self.request(identity: 0, urlString: self.sortRequest)
            }
            else {
                self.moviePage = 1
                self.request(identity: 0, urlString: self.movieRequest)
            }
        }
        
        self.moviesCollectionView.es_addInfiniteScrolling(animator: footerAnimator) {
            
            self.isMoreDataLoading = true
            
            if self.searchActive && self.searchRequest != "" {
                self.request(identity: 0, urlString: self.searchRequest)
            }
            else if self.isSorting {
                self.request(identity: 0, urlString: self.sortRequest)
            }
            else {
                self.request(identity: 0, urlString: self.movieRequest)
            }
        }
        
        // requst for data
        self.request(identity: 0, urlString: movieRequest)
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
        
        var movie : NSDictionary
        
        // check if searching
        if(searchActive){
            movie = searchResults[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
        
        cell.movie = movie
        
        if cell.movieImage.image == nil {
            cell.loadImage()
        }
        
        
        
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
                    
                    let original_title = movie.value(forKey: "original_title") as? String
                    let title = movie.value(forKey: "title") as? String
                    let overview = movie.value(forKey: "overview") as? String
                    let backdrop_path = movie.value(forKey: "backdrop_path") as? String
                    let poster_path = movie.value(forKey: "poster_path") as? String
                    let release_date = movie.value(forKey: "release_date") as? String
                    let original_language = movie.value(forKey: "original_language") as? String
                    
                    let id = movie.value(forKey: "id") as? Int
                    let popularity = movie.value(forKey: "popularity") as? Double
                    let vote_average = movie.value(forKey: "vote_average") as? Double
                    let vote_count = movie.value(forKey: "vote_count") as? Int
                    let runtime = movie.value(forKey: "runtime") as? Int
                    
                    let adult = movie.value(forKey: "adult") as? Bool

                    vc.movie = MovieModel(original_title: original_title, title : title, overview: overview, backdrop_path: backdrop_path, poster_path: poster_path, release_date: release_date, original_language: original_language, id: id!, popularity: popularity, vote_average: vote_average, vote_count: vote_count, runtime: runtime, adult: adult)
                }
            }
        }
    }
    
    // MARK : search bar controller >>>>>
    
    @IBAction func searchButtonTapped(_ sender: UIBarButtonItem) {
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
        self.helper.reloadDataWithAnimation(collectionView : self.moviesCollectionView)
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(MoviesViewController.autoHideKeyboardWhenTapOutside(sender: )))
        moviesCollectionView.addGestureRecognizer(tapGesture)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        moviesCollectionView.removeGestureRecognizer(tapGesture)
        
        if searchBar.text == "" {
            searchActive = false
            helper.reloadDataWithAnimation(collectionView : self.moviesCollectionView)
            
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
        moviesCollectionView.removeGestureRecognizer(tapGesture)
        moviesCollectionView.es_footer?.isHidden = true
        view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        moviesCollectionView.es_footer?.isHidden = false
        
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
        
        searchPage = 1
        
        helper.removeNotifyLabelCenter()
        
//        moviesCollectionView.es_startPullToRefresh()
        
        helper.scrollToTop(collectionView: moviesCollectionView)
        
        helper.reloadDataWithAnimation(collectionView : self.moviesCollectionView)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text != nil  {
            
            let query = searchBar.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            print(query)
            
            searchRequest = "\(requestPrefix)/search/movie?api_key=\(apiKey)&query=\(query)&page=\(searchPage)"
            
            moviesCollectionView.es_startPullToRefresh()
        }
        
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
        self.helper.reloadDataWithAnimation(collectionView : self.moviesCollectionView)
    }
    // <<<<< search bar controller
    
    // MARK : helper functions >>>>>

    
    // MARK : JSON request >>>
    func request (identity : Int, urlString : String) {
        
        NSLog("Data Loading...")
        
        helper.removeNotifyLabelCenter()
        
        UIView.animate(withDuration: 1.0, animations: {
            self.errorButton.isHidden = true
        })
        
        var requestString : String
        
        if searchActive {
            requestString = "\(self.searchRequest)&page=\(self.searchPage)"
        }
        else if isSorting {
            requestString = "\(self.sortRequest)&page=\(self.sortPage)"
        }
        else {
            requestString = "\(self.movieRequest)&page=\(self.moviePage)"
        }
        
        let url = URL(string: requestString)!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            self.helper.stopActivityIndicator()
            
            if let error = error {
                
                NSLog("Data Loading [Fail] \(error.localizedDescription)")
                
                self.searchBarButton.isEnabled = false
                
                if error.localizedDescription == "unsupported URL" {
                    self.moviesCollectionView.es_stopLoadingMore()
                }
                /// stop loading more data
                else if self.isMoreDataLoading {
                    self.errorToTop.constant = self.view.frame.height - 60 - self.errorButton.frame.height
                    
                    self.errorButton.setTitle("Network Error! Pull to Load", for: .normal)
                    UIView.animate(withDuration: 0.8, animations: {
                        self.loadViewIfNeeded()
                        self.errorButton.isHidden = false
                    })
                    self.moviesCollectionView.es_stopLoadingMore()
                }
                else {
                    self.errorToTop.constant = 0
                    self.errorButton.setTitle("Network Error! Pull to Refresh", for: .normal)
                    UIView.animate(withDuration: 0.8, animations: {
                        self.errorButton.isHidden = false
                    })
                    self.moviesCollectionView.es_stopPullToRefresh()
                }
                
                if self.movies.count != 0 {
                    self.errorButton.isUserInteractionEnabled = false
                } else {
                    self.errorButton.setTitle("Network Error! Tap to Refresh", for: .normal)
                }
            }
                
            else if let data = data {
                
                self.searchBarButton.isEnabled = true
                
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    
                    if identity == 0 {
                        self.assignMovieData(dataDictionary: dataDictionary)
                    }
                }
            }
            self.isMoreDataLoading = false
        }
        task.resume()
    }
    // <<< JSON request
    
    func assignMovieData (dataDictionary : NSDictionary) {
        
        if self.isMoreDataLoading {
            
            if ( dataDictionary["results"] as! [NSDictionary] ) == [] {
                // If no more data
                self.moviesCollectionView.es_noticeNoMoreData()
            }
            else {
                if searchActive {
                    NSLog("Data Loading [Success] search more \(self.searchPage)")
                    self.searchResults += dataDictionary["results"] as! [NSDictionary]
                    self.searchPage += 1
                }
                else if isSorting {
                    NSLog("Data Loading [Success] sort more \(self.sortPage)")
                    self.movies += dataDictionary["results"] as! [NSDictionary]
                    self.sortPage += 1
                }
                else {
                    NSLog("Data Loading [Success] load more \(self.moviePage)")
                    self.movies += dataDictionary["results"] as! [NSDictionary]
                    self.moviePage += 1
                }
                
                // If common end
                self.moviesCollectionView.es_stopLoadingMore()
            }
        }
            
        else {
            if searchActive {
                NSLog("Data Loading [Success] Search")
                self.searchResults = dataDictionary["results"] as! [NSDictionary]
                self.searchPage = 2
            }
            if isSorting {
                NSLog("Data Loading [Success] Sort")
                self.movies = dataDictionary["results"] as! [NSDictionary]
                self.sortPage = 2
            }
            else {
                NSLog("Data Loading [Success] load")
                self.movies = dataDictionary["results"] as! [NSDictionary]
                self.moviePage = 2
            }
            
            // Set ignore footer or not
            self.moviesCollectionView.es_stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
            
        }
        
        self.helper.reloadDataWithAnimation(collectionView : self.moviesCollectionView)
    }
    
    // <<<<< helper functions
}
