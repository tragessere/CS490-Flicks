//
//  DetailViewController.swift
//  Flicks
//
//  Created by Evan on 1/22/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var infoView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var overviewLabel: UILabel!

  var movie: NSDictionary!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame
    .origin.y + infoView.frame.size.height)
    
    
    let title = movie["title"] as! String
    let overview = movie["overview"] as! String
    
    titleLabel.text = title
    overviewLabel.text = overview
    overviewLabel.sizeToFit()
    
    let baseUrl = "http://image.tmdb.org/t/p/w500"
    if let posterPath = movie["poster_path"] as? String {
      //Hide image first either way to avoid the flickering when it's replaced
      posterImageView.image = nil
      
      let imageUrl = NSURL(string: baseUrl + posterPath)
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
            })
          } else {
            self.posterImageView.image = image
          }
        },
        failure: { (imageRequest, imageResponse, error) ->Void in
          
      })
    }
    
    
    
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

}
