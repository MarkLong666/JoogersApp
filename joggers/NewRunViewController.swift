//
//  NewRunViewController.swift
//  joggers
//
//  Created by Long Baolin on 16/3/15.
//  Copyright © 2016年 Lintasty. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import MediaPlayer

private let saveWorkoutSegueIdentifier = "saveWorkout"

class NewRunViewController: UIViewController, StepCountingDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseOrContinueButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var ruleView: UIView!
    @IBOutlet weak var distanceAndTimeComplainLabel: UILabel!
    @IBOutlet weak var discardButton: UIButton!
    @IBOutlet weak var albumImageIcon: UIImageView!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var musicDetailLabel: UILabel!
    @IBOutlet weak var playMusicContainerView: UIView!
    @IBOutlet weak var playOrPauseMusicButton: UIButton!
    
    //用来指示按键是否可以为一次运动而开始工作
    private var isInARunningLoop = false{
        didSet{
            if !isInARunningLoop {
                pauseOrContinueButton.setImage(UIImage(named: "tapToPauseIcon"), forState: .Normal)
            }
        }
    }
    
    //用来记录一次运动对象
    lazy private var workout: Jog = {
        let jog = Jog()
        jog.distance = 0
        jog.pace = 0
        jog.steps = 0
        jog.time = 0
        return jog
    }()
    
    //用于播放音乐的属性
    private lazy var myMusicPlayer = MPMusicPlayerController()
    private var musicIsPlaying = false{
        didSet{
            if musicIsPlaying {
                playOrPauseMusicButton.setTitle("Pause", forState: .Normal)
            }else{
                playOrPauseMusicButton.setTitle("Play", forState: .Normal)
            }
        }
    }
    
    @IBAction func playMusic(sender: UIBarButtonItem) {
        if playMusicContainerView.hidden {
            playMusicContainerView.hidden = false
            playMusicContainerView.alpha = 0
            let originalWidth = playMusicContainerView.bounds.width
            playMusicContainerView.layer.frame.size.width = 0
            UIView.animateWithDuration(0.2, animations: {
                self.playMusicContainerView.alpha = 1
                self.playMusicContainerView.layer.frame.size.width = originalWidth
            })
            
        }else{
                self.playMusicContainerView.hidden = true
        }
    }
    
    //用来展示跑步的距离，时间，速度，步数的四个Label
    //Distance
    @IBOutlet weak var distanceLabel: UILabel!
    private var previousLocation: CLLocation? = nil
    private var distance = 0.0{
        didSet{
            if distance == 0.0{
                distanceLabel.text = "0.00M"
            }else{
                distanceLabel.text = "\(Int(distance))m"
            }
        }
    }

    //Time
    @IBOutlet weak var timeLabel: UILabel!
    lazy private var timeCounter: RunningTimer = {
        [unowned self] in
        return RunningTimer(timeLabel: self.timeLabel)
    }()
    
    //Pace
    @IBOutlet weak var paceLabel: UILabel!
    
    //Step
    @IBOutlet weak var stepLabel: UILabel!
    lazy private var stepCounter: StepCounter = {
        let counter = StepCounter()
        counter.delegate = self
        return counter
    }()
    
    //StepCountingDelegate
    func didUpdateSteps(numberOfSteps: Int) {
        workout.steps = numberOfSteps
        stepLabel.text = "\(numberOfSteps)"
        
    }
    
    //指示跑步是否已经开始
    private var isRunning = false{
        didSet{
            if isRunning{
                locationManager.startMonitoringSignificantLocationChanges()
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                
                delay(seconds: 1, completion: {
                    self.locationManager.stopMonitoringSignificantLocationChanges()
                    self.locationManager.stopUpdatingHeading()
                    self.locationManager.stopUpdatingLocation()
                })
                
                delay(seconds: 1, completion: {
                    self.locationManager.startMonitoringSignificantLocationChanges()
                    self.locationManager.startUpdatingLocation()
                    self.locationManager.startUpdatingHeading()
                })
                

                
                }else{
                locationManager.stopMonitoringSignificantLocationChanges()
                locationManager.stopUpdatingHeading()
                locationManager.stopUpdatingLocation()
            }
        }
    }
    //长按使地图进入全屏幕或者半屏
    lazy private var isFullScreenMapOpen = false
    @IBAction func tapMapView(sender: UITapGestureRecognizer) {
        
        if !isFullScreenMapOpen{
            
            //当地图并不是在大屏状态时调整其自动布局参数使其进入大屏
            for constraint in mapView.superview!.constraints{
                
                if constraint.firstItem as! NSObject == mapView && constraint.firstAttribute == .Height{
                    
                    constraint.constant += ruleView.bounds.height
                    
                }
            }
            for constraint in mapView.superview!.constraints{
                
                if constraint.secondItem as? NSObject == pauseOrContinueButton && constraint.firstAttribute == .Top{
                    
                    constraint.constant -= self.view.bounds.height/4
                }
            }
            
            startButton.hidden = true
            pauseOrContinueButton.hidden = true
            endButton.hidden = true
            
        }else if isFullScreenMapOpen{
            
            //当地图处于大屏状态时调整其自动布局参数使其进入小屏
            for constraint in mapView.superview!.constraints{
                
                if constraint.firstItem as! NSObject == mapView && constraint.firstAttribute == .Height{
                    
                    constraint.constant = 0
                }
            }
            for constraint in mapView.superview!.constraints{
                
                if constraint.secondItem as? NSObject == pauseOrContinueButton && constraint.firstAttribute == .Top{
                    
                    constraint.constant += self.view.bounds.height/4
                }
            }
            
            startButton.hidden = false
            pauseOrContinueButton.hidden = false
            endButton.hidden = false
        }
        
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        isFullScreenMapOpen = !isFullScreenMapOpen
        
    }
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .Fitness
        locationManager.distanceFilter = 10.0
        
        locationManager.requestAlwaysAuthorization()
       
        return locationManager
    }()
    
    
    //底部四个按钮触发的事件
    //开始按钮
    @IBAction func startPressed() {

        mapView.showsUserLocation = true
        mapView.userTrackingMode = .FollowWithHeading

        isInARunningLoop = true
        stepCounter.startStepCounting()
        timeCounter.timingStart()
        isRunning = true
        
        
        for constraint in startButton.superview!.constraints{
            
            if constraint.secondItem as? NSObject == startButton && constraint.secondAttribute == .Trailing{
                
                constraint.constant += view.bounds.width/2
            }
        }
        UIView.animateWithDuration(0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 15, options: [], animations: {
            self.view.layoutIfNeeded()
            }, completion: { _ in
                self.discardButton.hidden = false
        })
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.removedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.startButton.layer.addAnimation(logoRotator, forKey: "logoRotator")
        
    }
    
   //暂停或继续按钮
    @IBAction func pauseOrPressedButtonPressed() {
        if !isInARunningLoop{
            return
        }
        
        if isRunning{
            stepCounter.pause()
            timeCounter.timingPause()
            pauseOrContinueButton.setImage(UIImage(named: "tapToContinueIcon"), forState: .Normal)
            isRunning = false
        }else if !isRunning{
            stepCounter.continueCounting()
            timeCounter.timingContinue()
            pauseOrContinueButton.setImage(UIImage(named: "tapToPauseIcon"), forState: .Normal)
            isRunning = true
        }
    }
    
    //结束按钮
    @IBAction func endPressed() {
        if !isInARunningLoop{
            return
        }
        isInARunningLoop = false
        workout.time = timeCounter.getCurrentRunningTime()
        timeCounter.timingPause()
        isRunning = false
        stepCounter.endStepCounting()
        
        let actionSheet = UIAlertController(title: "Running Complete", message: "Choose discard to restart or choose save to save this workout", preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Save", style: .Default, handler: { _ in
            self.resertToStart()
            self.performSegueWithIdentifier(saveWorkoutSegueIdentifier, sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Discard", style: .Default, handler: {_ in
            self.resertToStart()
            actionSheet.dismissViewControllerAnimated(true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == saveWorkoutSegueIdentifier{
            if let controller = segue.destinationViewController as? SaveAndShareViewController{
                controller.workout = self.workout
            }
        }
    }

    //抛弃这次运动按钮
    @IBAction func discardPressed() {
        if isRunning{
            isRunning = false
        }
        resertToStart()
    }
    
    func resertToStart() {
        isInARunningLoop = false
        UIView.animateWithDuration(0.3, animations: { _ in
            self.discardButton.alpha = 0
        })

        previousLocation = nil
        distance = 0
        timeCounter.resertToStart()
        paceLabel.text = "0"
        stepCounter.resetToStart()
        stepLabel.text = "0"
        
        for constraint in startButton.superview!.constraints{
            
            if constraint.secondItem as? NSObject == startButton && constraint.secondAttribute == .Trailing{
                
                constraint.constant = 20
            }
        }
        UIView.animateWithDuration(0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 15, options: [], animations: {
            self.view.layoutIfNeeded()
            }, completion: { _ in
                self.discardButton.alpha = 1.0
                self.discardButton.hidden = true
        })
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.removedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = 2 * M_PI
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.startButton.layer.addAnimation(logoRotator, forKey: "logoRotator")

    }
    
    //MARK: - ViewController lifecyle method
    override func viewDidLoad() {
        super.viewDidLoad()

        discardButton.hidden = true
        //将四个主按钮设置成圆形按钮
        pauseOrContinueButton.layer.cornerRadius = pauseOrContinueButton.layer.bounds.width/2
        pauseOrContinueButton.clipsToBounds = true
        discardButton.layer.cornerRadius = self.discardButton.layer.bounds.width/2
        discardButton.clipsToBounds = true
        startButton.layer.cornerRadius = startButton.layer.bounds.width/2
        endButton.layer.cornerRadius = endButton.layer.bounds.width/2
        startButton.clipsToBounds = true
        endButton.clipsToBounds = true
        
        //将视图放入side out menu 框架
        if revealViewController() != nil{
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = view.bounds.width * 0.7
            
            view.addGestureRecognizer(revealViewController().panGestureRecognizer())
        }
        
        //设置地图的随时定位
                //locationManager.startUpdatingLocation()
        //locationManager.startUpdatingHeading()
        
        //当前设备如果是iphone4s及以下设备时改变视图布局
        if UIScreen.mainScreen().bounds.size.height == 480.0{
            distanceAndTimeComplainLabel.removeFromSuperview()
        }
        
        playMusicContainerView.hidden = true
        nowPlayingItemIsChanged()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewRunViewController.stopMusic), name: UIApplicationWillTerminateNotification, object: nil)
        
    }
    
    

    //使用viewWillAppear和viewdidAppear来进行动画
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
       //移动视图中元素所处位置，为动画作准备
        for constraint in pauseOrContinueButton.superview!.constraints{
            if constraint.firstItem as? NSObject == pauseOrContinueButton && constraint.firstAttribute == .Leading{
                constraint.constant +=
                    self.view.bounds.size.width/2
            }
        }
        for constraint in endButton.superview!.constraints{
            if constraint.firstItem as? NSObject == endButton && constraint.firstAttribute == .Leading{
                constraint.constant += self.view.bounds.size.width/2
            }
        }
        for constraint in pauseOrContinueButton.superview!.constraints{
            if constraint.secondItem as? NSObject == pauseOrContinueButton && constraint.secondAttribute == .Bottom{
                constraint.constant -= self.view.bounds.size.height/2
            }
        }
        for constraint in mapView.superview!.constraints{
            if constraint.firstItem as? NSObject == mapView && constraint.firstAttribute == .Height{
                constraint.constant -= view.bounds.size.height * constraint.multiplier
            }
        }
        
        //准备音乐播放按钮
        if myMusicPlayer.playbackState == .Playing{
            musicIsPlaying = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //将视图元素的自动布局参数设回应有的数值
        for constraint in pauseOrContinueButton.superview!.constraints{
            if constraint.firstItem as? NSObject == pauseOrContinueButton && constraint.firstAttribute == .Leading{
                constraint.constant -=
                    self.view.bounds.size.width/2
            }
        }
        for constraint in endButton.superview!.constraints{
            if constraint.firstItem as? NSObject == endButton && constraint.firstAttribute == .Leading{
                constraint.constant -= self.view.bounds.size.width/2
            }
        }
        for constraint in pauseOrContinueButton.superview!.constraints{
            if constraint.secondItem as? NSObject == pauseOrContinueButton && constraint.secondAttribute == .Bottom{
                constraint.constant += self.view.bounds.size.height/2
            }
        }
        for constraint in mapView.superview!.constraints{
            if constraint.firstItem as? NSObject == mapView && constraint.firstAttribute == .Height{
                constraint.constant += view.bounds.size.height * constraint.multiplier
            }
        }

        //调用动画所需方法，开始动画
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: .CurveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
    }

    
}

extension NewRunViewController: CLLocationManagerDelegate{
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        dispatch_async(dispatch_get_main_queue()) {
            for location in locations{
                
                if location.horizontalAccuracy < 20{
                    if self.previousLocation == nil {
                        self.distance = 0
                    }
                    if self.previousLocation != nil{
                        self.distance += location.distanceFromLocation(self.previousLocation!)
                        self.workout.distance = Int(self.distance)
                        //每更新一次距离更新一次跑步速度
                        if self.isRunning{
                            let runningTime = self.timeCounter.getCurrentRunningTime()
                            if runningTime != 0{
                                let pace = Int(self.distance)/runningTime
                                self.workout.pace = pace
                                self.paceLabel.text = "\(pace)"
                            }
                        }
                    }
                    
                    self.previousLocation = location
                }
            }

        }
    }
}

extension NewRunViewController: MPMediaPickerControllerDelegate{
   
    func stopMusic(){
        myMusicPlayer.stop()
        musicIsPlaying = false
    }
    
    @IBAction func previousTrack() {
        myMusicPlayer.skipToPreviousItem()
    }
    
    
    @IBAction func pickSong() {
        let mediaPicker = MPMediaPickerController()
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = true
        presentViewController(mediaPicker, animated: true, completion: nil)
    }
    
    
    @IBAction func playOrPauseMusic() {
        if !musicIsPlaying{
            myMusicPlayer.play()
            musicIsPlaying = true
        }else{
            myMusicPlayer.pause()
            musicIsPlaying = false
        }

    }
    
    @IBAction func nextTrack() {
        myMusicPlayer.skipToNextItem()
        
    }
    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        myMusicPlayer.beginGeneratingPlaybackNotifications()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewRunViewController.nowPlayingItemIsChanged), name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification, object: myMusicPlayer)
        myMusicPlayer.setQueueWithItemCollection(mediaItemCollection)
        myMusicPlayer.repeatMode = .All
        myMusicPlayer.skipToBeginning()
        myMusicPlayer.play()
        musicIsPlaying = true
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        mediaPicker.dismissViewControllerAnimated(true, completion: nil)
    }

    func nowPlayingItemIsChanged(){
        
        if myMusicPlayer.nowPlayingItem != nil{
            let albumImage = myMusicPlayer.nowPlayingItem?.artwork?.imageWithSize(CGSizeZero)
            if albumImage != nil{
                self.albumImageIcon.image = albumImage
            }else{
                let image = UIImage(named: "albumIcon")
                self.albumImageIcon.image = image
            }
            
            musicNameLabel.text = (myMusicPlayer.nowPlayingItem?.title)! + "-" + (myMusicPlayer.nowPlayingItem?.artist)!
            musicDetailLabel.text = (myMusicPlayer.nowPlayingItem?.albumTitle)! + (myMusicPlayer.nowPlayingItem?.title)! + (myMusicPlayer.nowPlayingItem?.artist)! + (myMusicPlayer.nowPlayingItem!.genre)!
        }
    }
}
