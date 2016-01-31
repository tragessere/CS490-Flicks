//
//  DetailViewController.swift
//  Flicks
//
//  Created by Evan on 1/22/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var posterContainer: UIView!
  
  @IBOutlet weak var fadeInTitleView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var mpaaRatingLabel: UILabel!
  @IBOutlet weak var releaseDateLabel: UILabel!

  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var userRatingLabel: UILabel!
  @IBOutlet weak var taglineLabel: UILabel!
  @IBOutlet weak var taglineSeparator: UIView!
  @IBOutlet weak var overviewMarkerLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!
  @IBOutlet weak var overviewSeparator: UIView!
  @IBOutlet weak var genreMarkerLabel: UILabel!
  @IBOutlet weak var genreListLabel: UILabel!
  
  
  
  var movie: Movie!
  
  let posterResizeOffset: CGFloat = 200
  var fullHeight: CGFloat!
  var fullWidth: CGFloat!
  var step: CGFloat!
  
  var minimumInfoViewHeight: CGFloat!
  let smallPadding: CGFloat = 10
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    updateScrollViewSize()
    scrollView.delegate = self
    
    fullHeight = posterContainer.frame.height
    fullWidth = posterContainer.frame.width
    step = (1 - (scrollView.frame.size.width / fullWidth)) / posterResizeOffset
    
    let smallPosterHeight = posterImageView.frame.height * (scrollView.frame.size.width / fullWidth)
    
    minimumInfoViewHeight = UIScreen.mainScreen().bounds.height - smallPosterHeight + 108
    
    fadeInTitleView.frame = CGRectMake(
      fadeInTitleView.frame.origin.x,
      fadeInTitleView.frame.origin.y,
      scrollView.frame.size.width - (posterImageView.frame.width * (scrollView.frame.size.width / fullWidth)),
      smallPosterHeight)
    
    let title = movie.title
    let overview = movie.overview
    let rating = "Rating: \(movie.userRating) (Average of \(movie.userRatingCount) votes)"
    
    titleLabel.text = title
    titleLabel.sizeToFit()
    mpaaRatingLabel.layer.borderColor = UIColor.whiteColor().CGColor
    mpaaRatingLabel.layer.borderWidth = 1.0
    mpaaRatingLabel.sizeToFit()
    overviewLabel.text = overview
    userRatingLabel.text = rating
    
    titleLabel.frame = CGRectMake(
      titleLabel.frame.origin.x,
      titleLabel.frame.origin.y,
      scrollView.frame.size.width - (posterImageView.frame.width * (scrollView.frame.size.width / fullWidth)) - (2 * smallPadding),
      titleLabel.frame.height)
    mpaaRatingLabel.frame = CGRectMake(
      mpaaRatingLabel.frame.origin.x,
      titleLabel.frame.origin.y + titleLabel.frame.height,
      mpaaRatingLabel.frame.width,
      mpaaRatingLabel.frame.height)
    releaseDateLabel.frame = CGRectMake(
      releaseDateLabel.frame.origin.x,
      mpaaRatingLabel.frame.origin.y + mpaaRatingLabel.frame.height + smallPadding,
      releaseDateLabel.frame.width,
      releaseDateLabel.frame.height)
    
    organizeInfoView()
    
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let dateString = self.movie.releaseDate
    
    if let dateString = dateString {
      let releaseDate = dateFormatter.dateFromString(dateString)
      dateFormatter.dateFormat = "MMM dd, yyyy"
      self.releaseDateLabel.text = "Release Date: \(dateFormatter.stringFromDate(releaseDate!))"
      self.releaseDateLabel.sizeToFit()
    }
    
    
    let smallImageUrl = "http://image.tmdb.org/t/p/w45"
    if let posterPath = movie.posterPath {
      //Hide image first either way to avoid the flickering when it's replaced
      posterImageView.image = nil
      
      let imageUrl = NSURL(string: smallImageUrl + posterPath)
      let imageRequest = NSURLRequest(URL: imageUrl!)
      posterImageView.setImageWithURLRequest(
        imageRequest,
        placeholderImage: nil,
        success: { (imageRequest, imageResponse, image) -> Void in
          
          //Response is nil for a cached image
          if imageResponse != nil {
            self.posterImageView.alpha = 0
            self.posterImageView.image = image
            UIView.animateWithDuration(0.3, animations: { () -> Void in
              self.posterImageView.alpha = 1.0
              }, completion: { (success) -> Void in
                self.requestLargeImage()
            })
          } else {
            self.posterImageView.image = image
            
            self.requestLargeImage()
          }
          
          
        },
        failure: { (imageRequest, imageResponse, error) -> Void in
          
      })
    }
    
    loadRating()
    loadDetails()
  }
  
  override func viewWillDisappear(animated: Bool) {
    scrollView.delegate = nil
  }
  
  override func viewWillAppear(animated: Bool) {
    scrollView.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  //Gets the full size version of the poster image
  func requestLargeImage() {
    let posterPath = movie.posterPath!
    let largeImageUrl = "http://image.tmdb.org/t/p/original"
    let largeUrlRequest = NSURLRequest(URL: NSURL(string: largeImageUrl + posterPath)!)
    
    self.posterImageView.setImageWithURLRequest(
      largeUrlRequest,
      placeholderImage: nil,
      success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
        self.posterImageView.image = largeImage
      },
      failure: { (largeImageRequest, largeImageResponse, error) -> Void in
      }
    )

  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
  func scrollViewDidScroll(scrollView: UIScrollView) {
    //The navigation bar pushes the view down so an offset of -64 would be the top.
    let offset = scrollView.contentOffset.y + 64
    
    var sizeRatio: CGFloat!
    var posterContainerTop: CGFloat!
    
    if offset > 0 && offset < posterResizeOffset {   //Shrinking the top container. The position follows the scroll view to make it stick to the top
      sizeRatio = 1 - (offset * step)
      posterContainerTop = offset
    } else if offset <= 0 {           //Overscrolling on the top.
      sizeRatio = 1
      posterContainerTop = 0
    } else if offset >= posterResizeOffset {         //Scrolling down, done shrinking the top container.
      sizeRatio = 1 - (posterResizeOffset * step)
      posterContainerTop = posterResizeOffset
    }
    
    let containerHeight = fullHeight * sizeRatio
    posterContainer.frame = CGRectMake(0, posterContainerTop, fullWidth * sizeRatio, containerHeight)
    fadeInTitleView.frame = CGRectMake(posterImageView.frame.width, 0, fadeInTitleView.frame.width, fadeInTitleView.frame.height)
    infoView.frame = CGRectMake(0, containerHeight, infoView.frame.width, infoView.frame.height)
    
    updateScrollViewSize()
    
    let startFadeInOffset = posterResizeOffset / 4
    let endFadeInOffset = posterResizeOffset * 0.9
    
    var titleAlpha: CGFloat!
    if offset > startFadeInOffset && offset < endFadeInOffset {
      titleAlpha = (offset - startFadeInOffset) / (endFadeInOffset - startFadeInOffset)
    } else if offset <= startFadeInOffset {
      titleAlpha = 0
    } else if offset >= endFadeInOffset{
      titleAlpha = 1
    }
    
    fadeInTitleView.alpha = titleAlpha
    infoView.alpha = titleAlpha
  }
  
  //Calls the /movie/id/release_dates endpoint to get MPAA rating information
  func loadRating() {
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "Https://api.themoviedb.org/3/movie/\(movie.id)/release_dates?api_key=\(apiKey)")
    let request = NSURLRequest(URL: url!)
    let session = NSURLSession(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      delegate: nil,
      delegateQueue:  NSOperationQueue.mainQueue()
    )
    
    let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
      completionHandler: { (dataOrNil, response, error) in
        
        if let _ = error {
          print("details request error")
          return
        }
        
        if let data = dataOrNil {
          if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
            data, options:[]) as? NSDictionary {
              
              let allReleaseInformation = responseDictionary["results"] as? [NSDictionary]
              
              var movieReleaseInfo: NSDictionary?
              for releaseItem in allReleaseInformation! {
                if (releaseItem["iso_3166_1"] as! String) == "US" {
                  
                  let releaseDates = releaseItem["release_dates"] as! [NSDictionary]
                  
                  for releaseType in releaseDates {
                    if (releaseType["type"] as! Int) == 3 {
                      movieReleaseInfo = releaseType
                    }
                  }
                  
                  break
                }
              }
              
              if let movieReleaseInfo = movieReleaseInfo {
                var mpaaRating = movieReleaseInfo["certification"] as! String
                if mpaaRating == "" {
                  mpaaRating = "NR"
                }
                self.mpaaRatingLabel.text = " \(mpaaRating) "
                self.mpaaRatingLabel.sizeToFit()
              } else {
                self.mpaaRatingLabel.text = " NR "
                self.mpaaRatingLabel.sizeToFit()
                print("movieReleaseInfo was nil")
              }
          }
        }
    });
    task.resume()
  }

  //Calls the movie/id endpoint get genres and the tagline.
  func loadDetails() {
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    let url = NSURL(string: "Https://api.themoviedb.org/3/movie/\(movie.id)?api_key=\(apiKey)")
    let request = NSURLRequest(URL: url!)
    let session = NSURLSession(
      configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
      delegate: nil,
      delegateQueue:  NSOperationQueue.mainQueue()
    )
    
    let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
      completionHandler: { (dataOrNil, response, error) in
        
        if let _ = error {
          print("details request error")
          return
        }
        
        if let data = dataOrNil {
          if let movie = try! NSJSONSerialization.JSONObjectWithData(
            data, options:[]) as? NSDictionary {
              
              let tagline = movie["tagline"] as! String
              self.taglineLabel.text = tagline
              
              
              let genres = movie["genres"] as! [NSDictionary]
              
              var genreString = ""
              for genre in genres {
                genreString += (genre["name"] as! String)
                genreString += ", "
              }
              let range = genreString.endIndex.advancedBy(-2)..<genreString.endIndex
              genreString.removeRange(range)
              
              self.genreListLabel.text = genreString
              
              self.organizeInfoView()
          }
        }
    });
    task.resume()
  }
  
  
  //Resets the positions of views in the lower infoView after they have their information set
  func organizeInfoView() {
    let margin: CGFloat = 20
    
    taglineLabel.sizeToFit()
    taglineLabel.frame = CGRectMake(
      taglineLabel.frame.origin.x,
      userRatingLabel.frame.origin.y + userRatingLabel.frame.height + margin,
      taglineSeparator.frame.width,
      taglineLabel.frame.height)
    
    taglineSeparator.frame = CGRectMake(
      taglineSeparator.frame.origin.x,
      taglineLabel.frame.origin.y + taglineLabel.frame.height + margin,
      taglineSeparator.frame.width,
      taglineSeparator.frame.height)
    
    overviewMarkerLabel.frame = CGRectMake(
      overviewMarkerLabel.frame.origin.x,
      taglineSeparator.frame.origin.y + taglineSeparator.frame.height + margin,
      overviewMarkerLabel.frame.width,
      overviewMarkerLabel.frame.height)
    
    overviewLabel.sizeToFit()
    overviewLabel.frame = CGRectMake(
      overviewLabel.frame.origin.x,
      overviewMarkerLabel.frame.origin.y + overviewMarkerLabel.frame.height + margin,
      overviewLabel.frame.width,
      overviewLabel.frame.height)
    
    overviewSeparator.frame = CGRectMake(
      overviewSeparator.frame.origin.x,
      overviewLabel.frame.origin.y + overviewLabel.frame.height + margin,
      overviewSeparator.frame.width,
      overviewSeparator.frame.height)
    
    genreMarkerLabel.frame = CGRectMake(
      genreMarkerLabel.frame.origin.x,
      overviewSeparator.frame.origin.y + overviewSeparator.frame.height + margin,
      genreMarkerLabel.frame.width,
      genreMarkerLabel.frame.height)
    
    genreListLabel.frame = CGRectMake(
      genreListLabel.frame.origin.x,
      genreMarkerLabel.frame.origin.y + genreMarkerLabel.frame.height + margin,
      genreListLabel.frame.width,
      genreListLabel.frame.height)
    
    var totalHeight =
        userRatingLabel.frame.origin.y +
        userRatingLabel.frame.height +
        taglineLabel.frame.height +
        taglineSeparator.frame.height +
        overviewMarkerLabel.frame.height +
        overviewLabel.frame.height +
        overviewSeparator.frame.height +
        genreMarkerLabel.frame.height +
        genreListLabel.frame.height +
        (10 * margin) + 220
    
    if totalHeight < minimumInfoViewHeight {
      totalHeight = minimumInfoViewHeight
    }
    
    infoView.frame = CGRectMake(
      infoView.frame.origin.x,
      infoView.frame.origin.y,
      infoView.frame.width,
      totalHeight)
    
    updateScrollViewSize()
  }
  
  //The content size will be changing after updating some information from the server
  //as well as when the poster is resizing.
  func updateScrollViewSize() {
    let newHeight = posterContainer.frame.height + infoView.frame.height
    scrollView.contentSize = CGSize(width: scrollView.frame.width, height: newHeight)
  }
  
}
