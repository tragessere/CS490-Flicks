//
//  Movie.swift
//  Flicks
//
//  Created by Evan on 1/26/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

class Movie: NSObject {
  var id: Int
  
  var title: String
  var overview: String
  var userRating: CGFloat
  var userRatingCount: Int
  
  var releaseDate: String?
  var posterPath: String?
  
  init(fromDictionary data: NSDictionary) {
    id = data["id"] as! Int
    title = data["title"] as! String
    overview = data["overview"] as! String
    userRating = data["vote_average"] as! CGFloat
    userRatingCount = data["vote_count"] as! Int
    releaseDate = data["release_date"] as? String
    posterPath = data["poster_path"] as? String
  }
}
