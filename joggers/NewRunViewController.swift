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
    fileprivate var isInARunningLoop = false{
        didSet{
            if !isInARunningLoop {
                pauseOrContinueButton.setImage(UIImage(named: "tapToPauseIcon"), for: UIControlState())
            }
        }
    }
    
    //用来记录一次运动对象
    lazy fileprivate var workout: Jog = {
        let jog = Jog()
        jog.distance = 0
        jog.pace = 0
        jog.steps = 0
        jog.time = 0
        return jog
    }()
    
    //用于播放音乐的属性
    fileprivate lazy var myMusicPlayer = MPMusicPlayerController()
    fileprivate var musicIsPlaying = false{
        didSet{
            if musicIsPlaying {
                playOrPauseMusicButton.setTitle("Pause", for: UIControlState())
            }else{
                playOrPauseMusicButton.setTitle("Play", for: UIControlState())
            }
        }
    }
    
    @IBAction func playMusic(_ sender: UIBarButtonItem) {
        if playMusicContainerView.isHidden {
            playMusicContainerView.isHidden = false
            playMusicContainerView.alpha = 0
            let originalWidth = playMusicContainerView.bounds.width
            playMusicContainerView.layer.frame.size.width = 0
            UIView.animate(withDuration: 0.2, animations: {
                self.playMusicContainerView.alpha = 1
                self.playMusicContainerView.layer.frame.size.width = originalWidth
            })
            
        }else{
                self.playMusicContainerView.isHidden = true
        }
    }
    
    //用来展示跑步的距离，时间，速度，步数的四个Label
    //Distance
    @IBOutlet weak var distanceLabel: UILabel!
    fileprivate var previousLocation: CLLocation? = nil
    fileprivate var distance = 0.0{
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
    lazy fileprivate var timeCounter: RunningTimer = {
        [unowned self] in
        return RunningTimer(timeLabel: self.timeLabel)
    }()
    
    //Pace
    @IBOutlet weak var paceLabel: UILabel!
    
    //Step
    @IBOutlet weak var stepLabel: UILabel!
    lazy fileprivate var stepCounter: StepCounter = {
        let counter = StepCounter()
        counter.delegate = self
        return counter
    }()
    
    //StepCountingDelegate
    func didUpdateSteps(_ numberOfSteps: Int) {
        workout.steps = numberOfSteps
        stepLabel.text = "\(numberOfSteps)"
        
    }
    
    //指示跑步是否已经开始
    fileprivate var isRunning = false{
        didSet{
            if isRunning{
                
                //不知名的原因，反正开启定位的时候这么做就可以避免很多莫名其妙的bug
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
    lazy fileprivate var isFullScreenMapOpen = false
    @IBAction func tapMapView(_ sender: UITapGestureRecognizer) {
        
        if !isFullScreenMapOpen{
            
            //当地图并不是在大屏状态时调整其自动布局参数使其进入大屏
            for constraint in mapView.superview!.constraints{
                
                if constraint.firstItem as! NSObject == mapView && constraint.firstAttribute == .height{
                    
                    constraint.constant += ruleView.bounds.height
                    
                }
            }
            for constraint in mapView.superview!.constraints{
                
                if constraint.secondItem as? NSObject == pauseOrContinueButton && constraint.firstAttribute == .top{
                    
                    constraint.constant -= self.view.bounds.height/4
                }
            }
            
            startButton.isHidden = true
            pauseOrContinueButton.isHidden = true
            endButton.isHidden = true
            
        }else if isFullScreenMapOpen{
            
            //当地图处于大屏状态时调整其自动布局参数使其进入小屏
            for constraint in mapView.superview!.constraints{
                
                if constraint.firstItem as! NSObject == mapView && constraint.firstAttribute == .height{
                    
                    constraint.constant = 0
                }
            }
            for constraint in mapView.superview!.constraints{
                
                if constraint.secondItem as? NSObject == pauseOrContinueButton && constraint.firstAttribute == .top{
                    
                    constraint.constant += self.view.bounds.height/4
                }
            }
            
            startButton.isHidden = false
            pauseOrContinueButton.isHidden = false
            endButton.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        isFullScreenMapOpen = !isFullScreenMapOpen
        
    }
    
    fileprivate lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10.0
        
        locationManager.requestAlwaysAuthorization()
       
        return locationManager
    }()
    
    
    //底部四个按钮触发的事件
    //开始按钮
    @IBAction func startPressed() {

        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading

        isInARunningLoop = true
        stepCounter.startStepCounting()
        timeCounter.timingStart()
        isRunning = true
        
        
        for constraint in startButton.superview!.constraints{
            
            if constraint.secondItem as? NSObject == startButton && constraint.secondAttribute == .trailing{
                
                constraint.constant += view.bounds.width/2
            }
        }
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 15, options: [], animations: {
            self.view.layoutIfNeeded()
            }, completion: { _ in
                self.discardButton.isHidden = false
        })
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = -2 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.startButton.layer.add(logoRotator, forKey: "logoRotator")
        
    }
    
   //暂停或继续按钮
    @IBAction func pauseOrPressedButtonPressed() {
        if !isInARunningLoop{
            return
        }
        
        if isRunning{
            stepCounter.pause()
            timeCounter.timingPause()
            pauseOrContinueButton.setImage(UIImage(named: "tapToContinueIcon"), for: UIControlState())
            isRunning = false
        }else if !isRunning{
            stepCounter.continueCounting()
            timeCounter.timingContinue()
            pauseOrContinueButton.setImage(UIImage(named: "tapToPauseIcon"), for: UIControlState())
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
        
        let actionSheet = UIAlertController(title: "Running Complete", message: "Choose discard to restart or choose save to save this workout", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.resertToStart()
            self.performSegue(withIdentifier: saveWorkoutSegueIdentifier, sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Discard", style: .default, handler: {_ in
            self.resertToStart()
            actionSheet.dismiss(animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == saveWorkoutSegueIdentifier{
            if let controller = segue.destination as? SaveAndShareViewController{
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
        UIView.animate(withDuration: 0.3, animations: {
            self.discardButton.alpha = 0
        })

        previousLocation = nil
        distance = 0
        timeCounter.resertToStart()
        paceLabel.text = "0"
        stepCounter.resetToStart()
        stepLabel.text = "0"
        
        for constraint in startButton.superview!.constraints{
            
            if constraint.secondItem as? NSObject == startButton && constraint.secondAttribute == .trailing{
                
                constraint.constant = 20
            }
        }
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 15, options: [], animations: {
            self.view.layoutIfNeeded()
            }, completion: { _ in
                self.discardButton.alpha = 1.0
                self.discardButton.isHidden = true
        })
        
        let logoRotator = CABasicAnimation(keyPath: "transform.rotation.z")
        logoRotator.isRemovedOnCompletion = false
        logoRotator.fillMode = kCAFillModeForwards
        logoRotator.duration = 0.5
        logoRotator.fromValue = 0.0
        logoRotator.toValue = 2 * Double.pi
        logoRotator.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.startButton.layer.add(logoRotator, forKey: "logoRotator")

    }
    
    //MARK: - ViewController lifecyle method
    override func viewDidLoad() {
        super.viewDidLoad()

        discardButton.isHidden = true
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
        if UIScreen.main.bounds.size.height == 480.0{
            distanceAndTimeComplainLabel.removeFromSuperview()
        }
        
        playMusicContainerView.isHidden = true
        nowPlayingItemIsChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(NewRunViewController.stopMusic), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        
    }
    
    

    //使用viewWillAppear和viewdidAppear来进行动画
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       //移动视图中元素所处位置，为动画作准备
        for constraint in pauseOrContinueButton.superview!.constraints{
            if constraint.firstItem as? NSObject == pauseOrContinueButton && constraint.firstAttribute == .leading{
                constraint.constant +=
                    self.view.bounds.size.width/2
            }
        }
        for constraint in endButton.superview!.constraints{
            if constraint.firstItem as? NSObject == endButton && constraint.firstAttribute == .leading{
                constraint.constant += self.view.bounds.size.width/2
            }
        }
        for constraint in pauseOrContinueButton.superview!.constraints{
            if constraint.secondItem as? NSObject == pauseOrContinueButton && constraint.secondAttribute == .bottom{
                constraint.constant -= self.view.bounds.size.height/2
            }
        }
        for constraint in mapView.superview!.constraints{
            if constraint.firstItem as? NSObject == mapView && constraint.firstAttribute == .height{
                constraint.constant -= view.bounds.size.height * constraint.multiplier
            }
        }
        
        //准备音乐播放按钮
        if myMusicPlayer.playbackState == .playing{
            musicIsPlaying = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //将视图元素的自动布局参数设回应有的数值
        for constraint in pauseOrContinueButton.superview!.constraints{
            if constraint.firstItem as? NSObject == pauseOrContinueButton && constraint.firstAttribute == .leading{
                constraint.constant -=
                    self.view.bounds.size.width/2
            }
        }
        for constraint in endButton.superview!.constraints{
            if constraint.firstItem as? NSObject == endButton && constraint.firstAttribute == .leading{
                constraint.constant -= self.view.bounds.size.width/2
            }
        }
        for constraint in pauseOrContinueButton.superview!.constraints{
            if constraint.secondItem as? NSObject == pauseOrContinueButton && constraint.secondAttribute == .bottom{
                constraint.constant += self.view.bounds.size.height/2
            }
        }
        for constraint in mapView.superview!.constraints{
            if constraint.firstItem as? NSObject == mapView && constraint.firstAttribute == .height{
                constraint.constant += view.bounds.size.height * constraint.multiplier
            }
        }

        //调用动画所需方法，开始动画
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
    }

    
}

extension NewRunViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        DispatchQueue.main.async {
            for location in locations{
                
                if location.horizontalAccuracy < 20{
                    if self.previousLocation == nil {
                        self.distance = 0
                    }
                    if self.previousLocation != nil{
                        self.distance += location.distance(from: self.previousLocation!)
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
   
    @objc func stopMusic(){
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
        present(mediaPicker, animated: true, completion: nil)
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
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        myMusicPlayer.beginGeneratingPlaybackNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewRunViewController.nowPlayingItemIsChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: myMusicPlayer)
        myMusicPlayer.setQueue(with: mediaItemCollection)
        myMusicPlayer.repeatMode = .all
        myMusicPlayer.skipToBeginning()
        myMusicPlayer.play()
        musicIsPlaying = true
        mediaPicker.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        mediaPicker.dismiss(animated: true, completion: nil)
    }

    @objc func nowPlayingItemIsChanged(){
        
        if myMusicPlayer.nowPlayingItem != nil{
            let albumImage = myMusicPlayer.nowPlayingItem?.artwork?.image(at: CGSize.zero)
            if albumImage != nil{
                self.albumImageIcon.image = albumImage
            }else{
                let image = UIImage(named: "albumIcon")
                self.albumImageIcon.image = image
            }
            
            if let title = myMusicPlayer.nowPlayingItem?.title{
                if let artist = myMusicPlayer.nowPlayingItem?.artist{
                musicNameLabel.text = title + "-" + artist
                    if let albumTitle = myMusicPlayer.nowPlayingItem?.albumTitle{
                        if let genre =  myMusicPlayer.nowPlayingItem!.genre{
                            musicDetailLabel.text = albumTitle + title + artist + genre
                        }
                    }
                }
            }
        }
    }
}
