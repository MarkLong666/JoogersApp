//
//  CarouselShowHistoryViewController.swift
//  joggers
//
//  Created by Long Baolin on 16/3/18.
//  Copyright © 2016年 Lintasty. All rights reserved.
//

import UIKit
import CoreData

private let CollectionViewCellReuseIdentifier = "Cell"
private let DefaultImageName = "defaultView"
private let CollectionCellImageViewWidth = 250
private let CollectionCellIMageViewHeight = 320

class CarouselShowHistoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    private var pace = [Int]()
    private var steps = [Int]()
    private var image = [UIImage]()
    private var time = [String]()
    private var distance = [Int]()
    private var dateString = [String]()
    var dateFormatter: NSDateFormatter!
    var workouts: [Workout]!{
        didSet{
            for workout in workouts{
            if let photoData = workout.photo{
                let workoutImage = UIImage(data: photoData)
                image.append((workoutImage?.resizedImageWithBounds(CGSize(width: CollectionCellImageViewWidth*2, height: CollectionCellIMageViewHeight*2)))!)
            }else{
                image.append(UIImage(named: DefaultImageName)!)
            }
            time.append(getTimeStringFromSecond(workout.time!.integerValue))
            distance.append( workout.distance!.integerValue)
            dateString.append(dateFormatter.stringFromDate(workout.date!))
            steps.append(workout.steps!.integerValue)
            pace.append(workout.pace!.integerValue)
            }
        }
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
        
    @IBAction func goBackPressed() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - View controller lifecycle method
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = UIColor.clearColor()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if workouts.count == 3 {
        collectionView.scrollToItemAtIndexPath(NSIndexPath.init(forRow: 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
        }
    }
   
    //将statusbar字体改为白色以美化桌面
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    
    //MARK: UICollectionView dataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CollectionViewCellReuseIdentifier, forIndexPath: indexPath) as! HistoryCollectionCell
        cell.imageView.image = image[indexPath.row]
        cell.distanceLabel.text = "\(distance[indexPath.row])M"
        cell.dateLabel.text = dateString[indexPath.row]
        cell.timeLabel.text = "Time: \(time[indexPath.row])"
        cell.stepsLabel.text = "Steps: \(steps[indexPath.row])"
        cell.paceLabel.text = "Pace: \(pace[indexPath.row])"
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    
    
}
