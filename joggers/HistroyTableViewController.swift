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

    fileprivate var initiallyDisplayedCells = Int(UIScreen.main.bounds.size.height / CellHeight)
    fileprivate var viewDidAppear = false
    fileprivate var selectedIndexPath: IndexPath!
    
    fileprivate var spinner:UIActivityIndicatorView!
    
    fileprivate var managedContext: NSManagedObjectContext!
    
    fileprivate var workouts = [Workout]()
    fileprivate var dataFormatter = DateFormatter()
    fileprivate lazy var iconImages = [UIImage]()
    fileprivate lazy var runningTimes = [String]()
    fileprivate lazy var distances = [Int]()
    fileprivate lazy var dates = [String]()
    
    
    // MARK: - ViewController lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //workouts = []

        spinner = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x: tableView.layer.bounds.width/2,y: 0), size: CGSize(width: 20, height: 20)))
        spinner.color = UIColor.gray
        tableView.addSubview(spinner)
        spinner.startAnimating()
      
        dataFormatter.dateStyle = .medium
        dataFormatter.calendar = Calendar.current
        dataFormatter.timeStyle = .medium
       
        if revealViewController() != nil{
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            
            revealViewController().rearViewRevealWidth = view.bounds.width * 0.7
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        tableView.separatorColor = UIColor(red: 203/255, green: 232/255, blue: 225/255, alpha: 0.7)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appDelegate.managedObjectContext
        
        DispatchQueue.global().async {
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
                let time = getTimeStringFromSecond((workout.time?.intValue)!)
                self.runningTimes.append(time)
                let distance = workout.distance!.intValue
                self.distances.append(distance)
                let dateString = self.dataFormatter.string(from: workout.date!)
                self.dates.append(dateString)
                
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.spinner.removeFromSuperview()
            }
            
        }

       
    }
    
    func fetchWorkout(){
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
        do{
            workouts = try managedContext.fetch(request) as! [Workout]
        }catch let error as NSError{
            print("Error in fetch: \(error.localizedDescription)")
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppear = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewDidAppear = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowDetailSegueIdentifier {
            if let carouselViewController = segue.destination as? CarouselShowHistoryViewController{
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dates.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier) as! HistoryTableViewCell
        cell.runningTimeLabel.text = "Time: \(runningTimes[(indexPath as NSIndexPath).row])"
        cell.runningDistanceLabel.text = "RunningDistance: \(distances[(indexPath as NSIndexPath).row])"
        cell.dateLabel.text = dates[(indexPath as NSIndexPath).row]
        cell.iconImage = iconImages[(indexPath as NSIndexPath).row]
        
        return cell
        
    }
    
    // MARK: - TabelView delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row >= initiallyDisplayedCells || viewDidAppear {
            return
        }else{
            cell.layer.frame.origin.y += view.bounds.width
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 15, options: [], animations: {
                cell.layer.frame.origin.y -= self.view.bounds.width
                }, completion: nil)
                
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        managedContext.delete(workouts[(indexPath as NSIndexPath).row])
        workouts.remove(at: (indexPath as NSIndexPath).row)
        iconImages.remove(at: (indexPath as NSIndexPath).row)
        runningTimes.remove(at: (indexPath as NSIndexPath).row)
        distances.remove(at: (indexPath as NSIndexPath).row)
        dates.remove(at: (indexPath as NSIndexPath).row)
        
        DispatchQueue.global().async {
            do{
                try self.managedContext.save()
            }catch let error as NSError{
                print(error.localizedDescription)
            }

        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedIndexPath = indexPath
        return indexPath
    }
    
}
