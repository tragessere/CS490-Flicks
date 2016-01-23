//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Evan on 1/17/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UIScrollViewDelegate, UISearchResultsUpdating {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var errorView: UIView!
  @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
  @IBOutlet weak var searchContainer: UIView!
  
  var refreshControl: UIRefreshControl!
  var movies: [NSDictionary]?
  var filteredMovies: [NSDictionary]?
  var endpoint: String!
  
  var searchController: UISearchController!
  
  var loadingMoreView: InfiniteScrollActivityView?
  var attemptToLoadOnScroll = true
  var isMoreDataLoading = false
  var pageToLoad = 1

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.preferredStatusBarStyle()

    collectionView.dataSource = self
    collectionView.delegate = self
    
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.sectionInset = UIEdgeInsetsMake(105, 0, 0, 0)
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
    collectionView.insertSubview(refreshControl, atIndex: 0)
    
    searchController = UISearchController(searchResultsController: nil)
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    setupSearchBarStyle(searchController.searchBar)
    searchContainer.addSubview(searchController.searchBar)
    automaticallyAdjustsScrollViewInsets = false
    definesPresentationContext = true
    
    let frame = CGRectMake(0, collectionView.contentSize.height, collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
    loadingMoreView = InfiniteScrollActivityView(frame: frame)
    loadingMoreView!.hidden = true
    collectionView.addSubview(loadingMoreView!)
    
    var insets = collectionView.contentInset
    insets.bottom += InfiniteScrollActivityView.defaultHeight
    collectionView.contentInset = insets
    
    errorView.addGestureRecognizer(
        UITapGestureRecognizer(target: self, action: "onTouchErrorLabel"))
    
    
    loadMoreData()
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return UIStatusBarStyle.LightContent
  }
  
  func setupSearchBarStyle(searchBar: UISearchBar) {
    searchBar.sizeToFit()
    searchBar.keyboardAppearance = UIKeyboardAppearance.Dark
    searchBar.barStyle = UIBarStyle.BlackTranslucent
    searchBar.barTintColor = UIColor(hue: 0, saturation: 0, brightness: 0.15, alpha: 1)
    searchBar.tintColor = UIColor.whiteColor()
  }

  
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
    let cell = sender as! UICollectionViewCell
    let indexPath = collectionView.indexPathForCell(cell)
    let movie = movies![indexPath!.row]
    
    let detailViewController = segue.destinationViewController as! DetailViewController
    detailViewController.movie = movie
  }
  
  
  func refreshControlAction(refreshControl: UIRefreshControl) {
    pageToLoad = 1
    loadMoreData()
  }
  
  func onTouchErrorLabel() {
    loadMoreData()
  }
  
  
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if (!isMoreDataLoading){
      
      let scrollViewContentHeight = collectionView.contentSize.height
      let scrollOffsetThreshold = scrollViewContentHeight - collectionView.bounds.size.height
      
      if (scrollView.contentOffset.y > scrollOffsetThreshold && collectionView.dragging) {
        //Stop the app from repeatedly calling API at the bottom of the list
        if !attemptToLoadOnScroll {
          return
        }
        
        isMoreDataLoading = true
        attemptToLoadOnScroll = false
        
        let frame = CGRectMake(0, collectionView.contentSize.height, collectionView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
      
        loadMoreData()
      } else {
        attemptToLoadOnScroll = true
        loadingMoreView?.stopAnimating()
      }
      
    }
  }
  
  func updateSearchResultsForSearchController(searchController: UISearchController) {
    if let searchText = searchController.searchBar.text {
      filteredMovies = searchText.isEmpty ? movies : movies?.filter({(dataItem: NSDictionary) -> Bool in
        return (dataItem["title"] as! String).rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
      })
    }
    
    collectionView.reloadData()
  }
  
  
  func loadMoreData() {
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "Https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)&page=\(pageToLoad)")
    let request = NSURLRequest(URL: url!)
    let session = NSURLSession(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      delegate: nil,
      delegateQueue:  NSOperationQueue.mainQueue()
    )
    
    let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
      completionHandler: { (dataOrNil, response, error) in
        
        if let _ = error {
          self.errorView.hidden = false
          
          MBProgressHUD.hideHUDForView(self.view, animated: true)
          self.refreshControl.endRefreshing()
          self.isMoreDataLoading = false
          
          return
        } else {
          self.errorView.hidden = true
        }
        
        
        if let data = dataOrNil {
          if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
            data, options:[]) as? NSDictionary {
              //NSLog("response: \(responseDictionary)")
              
              if self.pageToLoad == 1 {
                //First page load
                self.movies = responseDictionary["results"] as? [NSDictionary]
              } else {
                self.movies = self.movies! + (responseDictionary["results"] as? [NSDictionary])!
              }
              
              self.updateSearchResultsForSearchController(self.searchController)
              
              self.collectionView.reloadData()
              
              MBProgressHUD.hideHUDForView(self.view, animated: true)
              self.refreshControl.endRefreshing()
              
              self.isMoreDataLoading = false
              self.pageToLoad++
          }
        }
    });
    task.resume()
  }
  
  
  func printAllTitles() {
    for (index, value) in movies!.enumerate() {
      print("\(index + 1): \(value["title"] as! String)")
    }
    print("")
  }

}
  
extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let movies = filteredMovies {
      return movies.count
    } else {
      return 0
    }
  }
  
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("com.evantragesser.MovieCell", forIndexPath: indexPath) as! MovieCell
    
    let baseUrl = "http://image.tmdb.org/t/p/w300"
    
    let movie = filteredMovies![indexPath.row]
    let title = movie["title"] as! String
    
    
    if let posterPath = movie["poster_path"] as? String {
      //Hide image first either way to avoid the flickering when it's replaced
      cell.posterView.image = nil
      
      let imageUrl = NSURL(string: baseUrl + posterPath)
      let imageRequest = NSURLRequest(URL: imageUrl!)
      cell.posterView.setImageWithURLRequest(
          imageRequest,
          placeholderImage: nil,
          success: { (imageRequest, imageResponse, image) -> Void in
            //Response is nil for a cached image
            if imageResponse != nil {
              cell.posterView.alpha = 0
              cell.posterView.image = image
              UIView.animateWithDuration(0.3, animations: { () -> Void in
                cell.posterView.alpha = 1.0
              })
            } else {
              cell.posterView.image = image
            }
          },
          failure: { (imageRequest, imageResponse, error) ->Void in
      
          })
    }
    
    cell.titleLabel.text = title
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    collectionView.deselectItemAtIndexPath(indexPath, animated: false)
  }
}
