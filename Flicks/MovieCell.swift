//
//  MovieCell.swift
//  Flicks
//
//  Created by Evan on 1/17/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

class MovieCell: UICollectionViewCell {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var posterView: UIImageView!
  


  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    
    let background = UIView()
    self.backgroundView = background
    self.backgroundView?.backgroundColor = UIColor.clearColor()
    
    let selectedBackground = UIView()
    self.selectedBackgroundView = selectedBackground
    self.selectedBackgroundView?.backgroundColor = UIColor.darkGrayColor()
    
  }

}
