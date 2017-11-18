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
    
    fileprivate var pace = [Int]()
    fileprivate var steps = [Int]()
    fileprivate var image = [UIImage]()
    fileprivate var time = [String]()
    fileprivate var distance = [Int]()
    fileprivate var dateString = [String]()
    var dateFormatter: DateFormatter!
    var workouts: [Workout]!{
        didSet{
            for workout in workouts{
            if let photoData = workout.photo{
                let workoutImage = UIImage(data: photoData as Data)
                image.append((workoutImage?.resizedImageWithBounds(CGSize(width: CollectionCellImageViewWidth*2, height: CollectionCellIMageViewHeight*2)))!)
            }else{
                image.append(UIImage(named: DefaultImageName)!)
            }
            time.append(getTimeStringFromSecond(workout.time!.intValue))
            distance.append( workout.distance!.intValue)
            dateString.append(dateFormatter.string(from: workout.date! as Date))
            steps.append(workout.steps!.intValue)
            pace.append(workout.pace!.intValue)
            }
        }
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
        
    @IBAction func goBackPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - View controller lifecycle method
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.backgroundColor = UIColor.clear

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if workouts.count == 3 {
        collectionView.scrollToItem(at: IndexPath.init(row: 1, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        }
    }
   
    //将statusbar字体改为白色以美化桌面
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    
    //MARK: UICollectionView dataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCellReuseIdentifier, for: indexPath) as! HistoryCollectionCell
        cell.imageView.image = image[(indexPath as NSIndexPath).row]
        cell.distanceLabel.text = "\(distance[(indexPath as NSIndexPath).row])M"
        cell.dateLabel.text = dateString[(indexPath as NSIndexPath).row]
        cell.timeLabel.text = "Time: \(time[(indexPath as NSIndexPath).row])"
        cell.stepsLabel.text = "Steps: \(steps[(indexPath as NSIndexPath).row])"
        cell.paceLabel.text = "Pace: \(pace[(indexPath as NSIndexPath).row])"
        cell.backgroundColor = UIColor.white
        return cell
    }
    
    
}
