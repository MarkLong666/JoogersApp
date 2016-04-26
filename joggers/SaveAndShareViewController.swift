//
//  SaveAndShareViewController.swift
//  joggers
//

//给动画设置慢一点的速度，就像QQ一样
//  Created by Long Baolin on 16/3/16.
//  Copyright © 2016年 Lintasty. All rights reserved.
//

import UIKit
import CoreData
import Social

private let TakePhotoSegueIdentifier = "takePhoto"

class SaveAndShareViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var infoTitleLabel: UILabel!
    @IBOutlet weak var distanceAndStepSatckView: UIStackView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discriptionLabel: UILabel!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var steplabel: UILabel!
    
    private var managedContext: NSManagedObjectContext!
    private var screenShotImage: UIImage!
    
    @IBAction func SavePressed() {
        saveButton.enabled = false
        let entity = NSEntityDescription.entityForName("Workout", inManagedObjectContext: managedContext)
        let workoutToSave = Workout(entity: entity!, insertIntoManagedObjectContext: managedContext)
        workoutToSave.date = workout.date
        workoutToSave.distance = workout.distance
        workoutToSave.pace = workout.pace
        workoutToSave.steps = workout.steps
        workoutToSave.time = workout.time
        if let image = workout.image {
            let imageData = UIImagePNGRepresentation(image)
            workoutToSave.photo = imageData
        }
        
    
        do{
            try managedContext.save()
        }catch let error as NSError{
            print("Error on Save: " + error.localizedDescription + "\(error.userInfo)")
        }
        
        let hudView = HudView.hudInView(navigationController!.view, animated: true)
        hudView.text = "Succeed"
        delay(seconds: 1) { 
            hudView.removeFromSuperview()
        }
    }
    
    
    @IBAction func sharePressed(sender: UIBarButtonItem) {
        getScreenShot()
        let shareActionSheet = UIAlertController(title: "分享到", message: nil, preferredStyle: .ActionSheet)
        shareActionSheet.addAction(UIAlertAction(title: "新浪微博", style: .Default, handler: { _ in self.sinaWeiboSharing()}))
        shareActionSheet.addAction(UIAlertAction(title: "腾讯微博", style: .Default, handler: { _ in self.tecentWeiboSharing()}))
        shareActionSheet.addAction(UIAlertAction(title: "facebook", style: .Default, handler: { _ in self.facebookSharing()}))
        shareActionSheet.addAction(UIAlertAction(title: "twitter", style: .Default, handler: { _ in self.twitterSharing()}))
        shareActionSheet.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: nil))
        presentViewController(shareActionSheet, animated: true, completion: nil)

    }
    
    func getScreenShot(){
        let layer = infoContainerView.layer
        //let layer = UIApplication.sharedApplication().keyWindow!.layer
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        screenShotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    //MARK: - different kinds of sharing
    func sinaWeiboSharing(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeSinaWeibo){
            let sinaWeboCompsor = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo)
            sinaWeboCompsor.setInitialText("今天的锻炼目标，完成!")
            sinaWeboCompsor.addImage(screenShotImage)
            presentViewController(sinaWeboCompsor, animated: true, completion: nil)
        }
        
    }
    
    func tecentWeiboSharing(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTencentWeibo){
            let tecentWeboCompor = SLComposeViewController(forServiceType: SLServiceTypeTencentWeibo)
            tecentWeboCompor.setInitialText("今天的锻炼目标，完成!")
            tecentWeboCompor.addImage(screenShotImage)
            presentViewController(tecentWeboCompor, animated: true, completion: nil)
        }
    }
    
    func facebookSharing(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            let facebookCompor = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookCompor.setInitialText("今天的锻炼目标，完成!")
            facebookCompor.addImage(screenShotImage)
            presentViewController(facebookCompor, animated: true, completion: nil)
        }
    }
    
    func twitterSharing(){
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterCompor = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterCompor.setInitialText("今天的锻炼目标，完成!")
            twitterCompor.addImage(screenShotImage)
            presentViewController(twitterCompor, animated: true, completion: nil)
        }
    }

    
    @IBAction func photoButtonPressed() {
        let alertController = UIAlertController(title: "Pick a photo", message: "Pick a photo from library or take a new photo", preferredStyle: .ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "from library", style: .Default, handler: { _ in
            self.choosePhotoFromLibrary()
        }))
        alertController.addAction(UIAlertAction(title: "new photo", style: .Default, handler: { _ in
            self.performSegueWithIdentifier(TakePhotoSegueIdentifier, sender: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func choosePhotoFromLibrary(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        presentViewController(imagePicker, animated: true
            , completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            workout.image = image
            let iconImage = image.resizedImageWithBounds(cameraButton.layer.bounds.size)
            cameraButton.setImage(iconImage, forState: .Normal)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    var workout: Jog = Jog(){
        didSet{
            workout.date = NSDate()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        steplabel.text = "\(workout.steps)steps"
        distanceLabel.text = "\(workout.distance)m"
        timeLabel.text = "Time: " + getTimeStringFromSecond(workout.time)
        
        //调整视图
        infoContainerView.layer.cornerRadius = 10
        cameraButton.layer.cornerRadius = 4
        cameraButton.clipsToBounds = true
        
        //当设备是iphone4s及以下设备时修复视图布局
        if UIScreen.mainScreen().bounds.size.height == 480.0{
            
            for constraint in infoTitleLabel.superview!.constraints{
                
                if constraint.firstItem as? NSObject == infoTitleLabel && constraint.firstAttribute == .Top{
                    constraint.constant -= 10
                }
            }
            for constraint in cameraButton.superview!.constraints{
                
                if constraint.firstItem as? NSObject == cameraButton && constraint.firstAttribute == .Top{
                    constraint.constant -= 10
                }
            }
            
            for constraint in timeLabel.superview!.constraints{
                if constraint.firstItem as? NSObject == timeLabel && constraint.firstAttribute == .Top{
                    constraint.constant -= 15
                }
            }
        }
        
        let appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedContext = appdelegate.managedObjectContext
        
        NSNotificationCenter.defaultCenter().addObserverForName(PhotoCaptureNotification.photoInfoNotificationName, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) in
            let image = notification.userInfo!["photo"] as! UIImage
            self.workout.image = image
            let iconImage = image.resizedImageWithBounds(self.cameraButton.layer.bounds.size)
            self.cameraButton.setImage(iconImage, forState: .Normal)
        }

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //将用于动画的控件的自动布局参数改变使的它们移出界面以准备动画
        for constraint in infoTitleLabel.superview!.constraints{
            
            if constraint.firstItem as? NSObject == infoTitleLabel && constraint.firstAttribute == .Top{
                constraint.constant -= view.bounds.height/2
            }
        }
        for constraint in distanceAndStepSatckView.superview!.constraints{
            
            if constraint.firstItem as? NSObject == distanceAndStepSatckView && constraint.firstAttribute == .CenterX{
                constraint.constant -= view.bounds.width
            }
        }
        for constraint in timeLabel.superview!.constraints{
            
            if constraint.firstItem as? NSObject == timeLabel && constraint.firstAttribute == .CenterX{
                constraint.constant += view.bounds.width
            }
        }
        for constraint in discriptionLabel.superview!.constraints{
            
            if constraint.secondItem as? NSObject == discriptionLabel && constraint.firstAttribute == .Bottom{
                constraint.constant -= view.bounds.height
            }
        }
        for constraint in infoContainerView.superview!.constraints{
            
            if constraint.firstItem as? NSObject == infoContainerView && constraint.firstAttribute == .Height{
                constraint.constant -= view.bounds.height * constraint.multiplier
            }
        }
        
        //将照相机图标隐藏为动画做准备
        cameraButton.alpha = 0.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //将被用于动画的界面元素的自动布局参数设回原值
        for constraint in infoTitleLabel.superview!.constraints{
            
            if constraint.firstItem as? NSObject == infoTitleLabel && constraint.firstAttribute == .Top{
                constraint.constant += view.bounds.height/2
            }
        }
        for constraint in distanceAndStepSatckView.superview!.constraints{
            
            if constraint.firstItem as? NSObject == distanceAndStepSatckView && constraint.firstAttribute == .CenterX{
                constraint.constant += view.bounds.width
            }
        }
        for constraint in timeLabel.superview!.constraints{
            
            if constraint.firstItem as? NSObject == timeLabel && constraint.firstAttribute == .CenterX{
                constraint.constant -= view.bounds.width
            }
        }
        for constraint in discriptionLabel.superview!.constraints{
            
            if constraint.secondItem as? NSObject == discriptionLabel && constraint.firstAttribute == .Bottom{
                constraint.constant += view.bounds.height
            }
        }
        for constraint in infoContainerView.superview!.constraints{
            
            if constraint.firstItem as? NSObject == infoContainerView && constraint.firstAttribute == .Height{
                constraint.constant += view.bounds.height * constraint.multiplier
            }
        }

        //将控件移动回原处的动画
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 15, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        //将照相机图标显示出来的动画
        UIView.animateWithDuration(1.0, delay: 0.3, options: [], animations: {
            self.cameraButton.alpha = 1.0
            }, completion: nil)
        
        }
    
   }
