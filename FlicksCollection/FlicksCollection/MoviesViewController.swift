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
    
    @IBOutlet weak var popularityButton: UIButton!
    
    @IBOutlet weak var rateButton: UIButton!
    
    @IBOutlet weak var searchBarButton: UIBarButtonItem!
    
    @IBOutlet weak var menuBarButton: UIBarButtonItem!
    
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
    
    // dropdown menu dropped
    var isDropped = false
    
    // loading page > 1
    var isMoreDataLoading = false
    
    // page number for request +1 when request data successfully
    var page = 1
    
    // orange color
    let highlightColor = UIColor(red: 1, green: 149/255, blue: 0, alpha: 1)
    
    // <<<<< variables
    
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
        sortKey(byKey: "release_date")
        helper.scrollToTop(collectionView : moviesCollectionView)
    }
    
    @IBAction func popularTapped(_ sender: UIButton) {
        resetFilterButtonColor()
        sender.setTitleColor(highlightColor, for: .normal)
        filterButton.setTitle("Popularity", for: .normal)
        hideDrodown()
        sortKey(byKey: "popularity")
        helper.scrollToTop(collectionView : moviesCollectionView)
    }
    @IBAction func rateTapped(_ sender: UIButton) {
        resetFilterButtonColor()
        sender.setTitleColor(highlightColor, for: .normal)
        filterButton.setTitle("Rate", for: .normal)
        hideDrodown()
        sortKey(byKey: "vote_average")
        helper.scrollToTop(collectionView : moviesCollectionView)
    }
    
    func resetFilterButtonColor () {
        rateButton.setTitleColor(.white, for: .normal)
        recentButton.setTitleColor(.white, for: .normal)
        popularityButton.setTitleColor(.white, for: .normal)
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
        
        // setup collection view layout
        helper.collectionViewLayoutSetup(collectionView: self.moviesCollectionView, view : self)
        
        searchBar.isHidden = true
        
        popularityButton.setTitleColor(highlightColor, for: .normal)
        
        // hide searchBar when search button not clicked
        collectionToSearch.constant = -44
        
        // dropdown menu setup
        dropDownImg.layer.masksToBounds = true
        dropDownImg.layer.cornerRadius = 10
        dropdownView.isHidden = true
        
        
        
        /// Custom refreshController
        self.moviesCollectionView.es_addPullToRefresh(animator: headerAnimator) {
            
            print("func")
            
            self.page = 1
            self.filterButton.setTitle("Now Playing", for: .normal)
            self.resetFilterButtonColor()
            self.request()
        }
        
        self.moviesCollectionView.es_addInfiniteScrolling(animator: footerAnimator) {
            
            self.isMoreDataLoading = true
            self.request()
        }
        
        moviesCollectionView.expriedTimeInterval = 10.0
        moviesCollectionView.es_autoPullToRefresh()
        
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
        
        var movie : NSDictionary
        
        // check if searching
        if(searchActive){
            movie = searchResults[indexPath.row]
        } else {
            movie = movies[indexPath.row]
        }
        
        cell.movie = movie
        
        cell.loadImage()
        
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

                    vc.movie = MovieModel(original_title:( original_title ?? ""), overview: (overview ?? ""), backdrop_path: (backdrop_path ?? ""), poster_path: (poster_path ?? ""), release_date: (release_date ?? ""), original_language: (original_language ?? ""), id: (id ?? 0), popularity: (popularity ?? 0.0), vote_average: (vote_average ?? 0.0), vote_count: (vote_count ?? 0), runtime: (runtime ?? 0), adult: (adult ?? false))
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
        
        helper.reloadDataWithAnimation(collectionView : self.moviesCollectionView)
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
        self.helper.reloadDataWithAnimation(collectionView : self.moviesCollectionView)
    }
    // <<<<< search bar controller
    
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
        helper.reloadDataWithAnimation(collectionView : self.moviesCollectionView)
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
    
    // MARK : JSON request >>>
    func request () {
        
        NSLog("Data Loading...")
        
        helper.removeNotifyLabelCenter()
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)&page=\(page)")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            self.helper.stopActivityIndicator()
            
            if let error = error {
                
                NSLog("Data Loading [Fail] \(error.localizedDescription)")
                
                self.searchBar.isUserInteractionEnabled = false
                
                /// stop loading more data
                if self.isMoreDataLoading {
                    
                }
            }
                
            else if let data = data {
                
                self.searchBar.isUserInteractionEnabled = true
                
                if let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                    
                    if self.isMoreDataLoading {
                        
                        NSLog("Data Loading [Success] page\(self.page)")
                        
                        if ( dataDictionary["results"] as! [NSDictionary] ) == [] {
                            // If no more data
                            self.moviesCollectionView.es_noticeNoMoreData()
                            
                        } else {
                            self.movies += dataDictionary["results"] as! [NSDictionary]
                            
                            // If common end
                            self.moviesCollectionView.es_stopLoadingMore()
                        }
                    }
                    
                    else {
                        
                        NSLog("Data Loading [Success] refresh : page\(self.page)")
                        
                        self.movies = dataDictionary["results"] as! [NSDictionary]
                        
                        // Set ignore footer or not
                        self.moviesCollectionView.es_stopPullToRefresh(ignoreDate: true, ignoreFooter: false)
                        
                        self.filterButton.setTitle("Now Playing", for: .normal)
                    }
                    
                    self.helper.reloadDataWithAnimation(collectionView : self.moviesCollectionView)
                    
                    self.tabBarController?.tabBar.items?[0].badgeValue = "\(self.movies.count)"
                }
                self.page += 1
            }
            self.isMoreDataLoading = false
        }
        task.resume()
    }
    // <<< JSON request
    
    // <<<<< helper functions
}
