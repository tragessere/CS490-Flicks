//
//  CollectionViewController.swift
//  Flicks
//
//  Created by Evan on 1/18/16.
//  Copyright © 2016 EvanTragesser. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
  
  let totalColors: Int = 100
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    collectionView.delegate = self
    
    flowLayout.scrollDirection = .Horizontal
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
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
  
  
  func colorForIndexPath(indexPath: NSIndexPath) -> UIColor {
    if indexPath.row >= totalColors {
      return UIColor.blackColor()
    }
    
    let hueValue: CGFloat = CGFloat(indexPath.row) / CGFloat(totalColors)
    return UIColor(hue: hueValue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
  }

  
}


extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return totalColors
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("com.evantragesser.ColorCell", forIndexPath: indexPath) as! ColorCell
    let cellColor = colorForIndexPath(indexPath)
    cell.backgroundColor = cellColor
    
    if CGColorGetNumberOfComponents(cellColor.CGColor) == 4 {
      let redComponent = CGColorGetComponents(cellColor.CGColor)[0] * 255
      let greenComponent = CGColorGetComponents(cellColor.CGColor)[0] * 255
      let blueComponent = CGColorGetComponents(cellColor.CGColor)[0] * 255
      cell.colorLabel.text = String(format: "%.0f, %.0f, %.0f", redComponent, greenComponent, blueComponent)
    }
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let totalWidth = collectionView.bounds.size.width
    let numberOfCellsPerRow = 3
    let oddEven = indexPath.row / numberOfCellsPerRow % 2
    let dimensions = CGFloat(Int(totalWidth) / numberOfCellsPerRow)
    if oddEven == 0 {
      return CGSizeMake(dimensions, dimensions)
    } else {
      return CGSizeMake(dimensions, dimensions / 2)
    }
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    print("Selected cell number: \(indexPath.row)")
  }
}
