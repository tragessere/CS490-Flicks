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

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
  @IBOutlet weak var tableView: UITableView!
  
  var refreshControl: UIRefreshControl!
  var movies: [NSDictionary]?
  
  var loadingMoreView: InfiniteScrollActivityView?
  var isMoreDataLoading = false
  var pageToLoad = 1

  override func viewDidLoad() {
      super.viewDidLoad()

    tableView.dataSource = self
    tableView.delegate = self
    
    refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
    tableView.insertSubview(refreshControl, atIndex: 0)
    
    let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
    loadingMoreView = InfiniteScrollActivityView(frame: frame)
    loadingMoreView!.hidden = true
    tableView.addSubview(loadingMoreView!)
    
    var insets = tableView.contentInset
    insets.bottom += InfiniteScrollActivityView.defaultHeight
    tableView.contentInset = insets
    
    loadMoreData()
    
    
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
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
    loadMoreData()
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let movies = movies {
      return movies.count
    } else {
      return 0
    }
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
    
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    
    let movie = movies![indexPath.row]
    let title = movie["title"] as! String
    let overview = movie["overview"] as! String
    
    
    if let posterPath = movie["poster_path"] as? String {
      let imageUrl = NSURL(string: baseUrl + posterPath)
      cell.posterView.setImageWithURL(imageUrl!)
    }
    
    
    cell.titleLabel.text = title
    cell.overviewLabel.text = overview
    
    return cell
  }
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    if !isMoreDataLoading {
      
      let scrollViewContentHeight = tableView.contentSize.height
      let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
      
      if (scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
        isMoreDataLoading = true
        
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView?.frame = frame
        loadingMoreView!.startAnimating()
      
        loadMoreData()
      } else {
        loadingMoreView?.stopAnimating()
      }
      
    }
  }
  
  
  func loadData() {
    MBProgressHUD.showHUDAddedTo(self.view, animated: true)
    
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
    let request = NSURLRequest(URL: url!)
    let session = NSURLSession(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      delegate:nil,
      delegateQueue:NSOperationQueue.mainQueue()
    )
    
    let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
      completionHandler: { (dataOrNil, response, error) in
        if let data = dataOrNil {
          if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
            data, options:[]) as? NSDictionary {
              
              self.movies = responseDictionary["results"] as? [NSDictionary]
              self.tableView.reloadData()
              
              MBProgressHUD.hideHUDForView(self.view, animated: true)
              self.refreshControl.endRefreshing()
              
              
              self.isMoreDataLoading = false
          }
        }
    });
    task.resume()
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
          //TODO: show error message
          return
        } else {
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
              
              self.tableView.reloadData()
              
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
