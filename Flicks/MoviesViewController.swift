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

class MoviesViewController: UIViewController, UIScrollViewDelegate {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var errorView: UIView!
  @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
  
  var refreshControl: UIRefreshControl!
  var movies: [NSDictionary]?
  
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
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
    collectionView.insertSubview(refreshControl, atIndex: 0)
    
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

  /*
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      // Get the new view controller using segue.destinationViewController.
      // Pass the selected object to the new view controller.
  }
  */
  
  
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
  
  
  func loadMoreData() {
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "Https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)&page=\(pageToLoad)")
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
          print("network error")
          
          MBProgressHUD.hideHUDForView(self.view, animated: true)
          self.refreshControl.endRefreshing()
          self.isMoreDataLoading = false
          
          return
        } else {
          self.errorView.hidden = true
          print("error was nil (there were no network errors)")
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
                self.printAllTitles()
              }
              
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
    if let movies = movies {
      return movies.count
    } else {
      return 0
    }
  }
  
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("com.evantragesser.MovieCell", forIndexPath: indexPath) as! MovieCell
    
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    
    let movie = movies![indexPath.row]
    let title = movie["title"] as! String
    
    
    if let posterPath = movie["poster_path"] as? String {
      let imageUrl = NSURL(string: baseUrl + posterPath)
      cell.posterView.setImageWithURL(imageUrl!)
    }
    
    
    cell.titleLabel.text = title
    
    return cell
  }
  
  
//  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//    let totalWidth = collectionView.bounds.size.width
//    let numberOfCellsPerRow = 2
//    let cellWidth = CGFloat(Int(totalWidth) / numberOfCellsPerRow)
//    let cellHeight = CGFloat(cellWidth * 1.5)
//    
//    
//    
//    return CGSizeMake(cellWidth, cellHeight)
//  }
  
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    print("Selected cell number: \(indexPath.row)")
  }
}
