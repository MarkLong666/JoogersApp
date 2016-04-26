//
//  HistroyTableViewController.swift
//  joggers
//
//  Created by Long Baolin on 16/3/15.
//  Copyright © 2016年 Lintasty. All rights reserved.
//

import UIKit
import CoreData

private let CellIdentifier = "HistoryTableViewCell"
private let CellHeight: CGFloat = 60
private let DefaultImageIconName = "defaultView"
private let ShowDetailSegueIdentifier = "showWorkoutDetail"
private let DefaultIconWidth = 120
private let DefaultIconHeight = 120

class HistroyTableViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!

    private var initiallyDisplayedCells = Int(UIScreen.mainScreen().bounds.size.height / CellHeight)
    private var viewDidAppear = false
    private var selectedIndexPath: NSIndexPath!
    
    private var spinner:UIActivityIndicatorView!
    
    private var managedContext: NSManagedObjectContext!
    
    private var workouts = [Workout]()
    private var dataFormatter = NSDateFormatter()
    private lazy var iconImages = [UIImage]()
    private lazy var runningTimes = [String]()
    private lazy var distances = [Int]()
    private lazy var dates = [String]()
    
    
    // MARK: - ViewController lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //workouts = []

        spinner = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: tableView.layer.bounds.width/2,y: 0), size: CGSize(width: 20, height: 20)))
        spinner.color = UIColor.grayColor()
        tableView.addSubview(spinner)
        spinner.startAnimating()
      
        dataFormatter.dateStyle = .MediumStyle
        dataFormatter.calendar = NSCalendar.currentCalendar()
        dataFormatter.timeStyle = .MediumStyle
       
        if revealViewController() != nil{
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rearViewRevealWidth = view.bounds.width * 0.7
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        tableView.separatorColor = UIColor(red: 203/255, green: 232/255, blue: 225/255, alpha: 0.7)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            self.fetchWorkout()
            //获取到数据后对数据进行解析
            for workout in self.workouts{
                if let photoData = workout.photo{
                    var image = UIImage(data: photoData)
                    image = image?.resizedImageWithBounds(CGSize(width: DefaultIconWidth, height: DefaultIconHeight))
                    self.iconImages.append(image!)
                }else{
                    let image = UIImage(named: DefaultImageIconName)?.resizedImageWithBounds(CGSize(width: DefaultIconWidth, height: DefaultIconHeight))
                    self.iconImages.append(image!)
                }
                let time = getTimeStringFromSecond((workout.time?.integerValue)!)
                self.runningTimes.append(time)
                let distance = workout.distance!.integerValue
                self.distances.append(distance)
                let dateString = self.dataFormatter.stringFromDate(workout.date!)
                self.dates.append(dateString)
                
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                self.spinner.removeFromSuperview()
            }
            
        }

       
    }
    
    func fetchWorkout(){
        
        let request = NSFetchRequest(entityName: "Workout")
        do{
            workouts = try managedContext.executeFetchRequest(request) as! [Workout]
        }catch let error as NSError{
            print("Error in fetch: \(error.localizedDescription)")
        }
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppear = true
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewDidAppear = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ShowDetailSegueIdentifier {
            if let carouselViewController = segue.destinationViewController as? CarouselShowHistoryViewController{
                carouselViewController.dateFormatter = self.dataFormatter
                var workoutsToPass = [Workout]()
                if selectedIndexPath.row == 0 {
                    if workouts.count == 1{
                        workoutsToPass.append(workouts[0])
                    }else{
                        workoutsToPass.append(workouts[0])
                        workoutsToPass.append(workouts[1])
                    }
                }else if selectedIndexPath.row == workouts.count - 1{
                    workoutsToPass.append(workouts[workouts.count-1])
                    workoutsToPass.append(workouts[workouts.count-2])
                }else{
                    workoutsToPass.append(workouts[selectedIndexPath.row-1])
                    workoutsToPass.append(workouts[selectedIndexPath.row])
                    workoutsToPass.append(workouts[selectedIndexPath.row+1])
                }
                carouselViewController.workouts = workoutsToPass
            }
            
        }
    }
   
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! HistoryTableViewCell
        cell.runningTimeLabel.text = "Time: \(runningTimes[indexPath.row])"
        cell.runningDistanceLabel.text = "RunningDistance: \(distances[indexPath.row])"
        cell.dateLabel.text = dates[indexPath.row]
        cell.iconImage = iconImages[indexPath.row]
        
        return cell
        
    }
    
    // MARK: - TabelView delegate
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row >= initiallyDisplayedCells || viewDidAppear {
            return
        }else{
            cell.layer.frame.origin.y += view.bounds.width
            UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 15, options: [], animations: {
                cell.layer.frame.origin.y -= self.view.bounds.width
                }, completion: nil)
                
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        managedContext.deleteObject(workouts[indexPath.row])
        workouts.removeAtIndex(indexPath.row)
        iconImages.removeAtIndex(indexPath.row)
        runningTimes.removeAtIndex(indexPath.row)
        distances.removeAtIndex(indexPath.row)
        dates.removeAtIndex(indexPath.row)
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {
            do{
                try self.managedContext.save()
            }catch let error as NSError{
                print(error.localizedDescription)
            }

        }
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedIndexPath = indexPath
        return indexPath
    }
    
}
