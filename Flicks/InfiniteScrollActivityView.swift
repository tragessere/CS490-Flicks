//
//  InfiniteScrollActivityView.swift
//  Flicks
//
//  Created by Evan on 1/18/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

class InfiniteScrollActivityView: UIView {
  var activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView()
  static let defaultHeight: CGFloat = 60.0
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupActivityIndicator()
  }
  
  override init(frame aRect: CGRect) {
    super.init(frame: aRect)
    setupActivityIndicator()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    activityIndicatorView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)
  }
  
  func setupActivityIndicator() {
    activityIndicatorView.activityIndicatorViewStyle = .Gray
    activityIndicatorView.hidesWhenStopped = true
    self.addSubview(activityIndicatorView)
  }
  
  func startAnimating() {
    self.hidden = false
    self.activityIndicatorView.startAnimating()
  }
  
  func stopAnimating() {
    self.activityIndicatorView.stopAnimating()
    self.hidden = true
  }
}
