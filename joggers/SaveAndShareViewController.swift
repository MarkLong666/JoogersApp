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
    
    fileprivate var managedContext: NSManagedObjectContext!
    fileprivate var screenShotImage: UIImage!
    
    @IBAction func SavePressed() {
        saveButton.isEnabled = false
        let entity = NSEntityDescription.entity(forEntityName: "Workout", in: managedContext)
        let workoutToSave = Workout(entity: entity!, insertInto: managedContext)
        workoutToSave.date = workout.date
        workoutToSave.distance = workout.distance as NSNumber?
        workoutToSave.pace = workout.pace as NSNumber?
        workoutToSave.steps = workout.steps as NSNumber?
        workoutToSave.time = workout.time as NSNumber?
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
    
    
    @IBAction func sharePressed(_ sender: UIBarButtonItem) {
        getScreenShot()
        let shareActionSheet = UIAlertController(title: "分享到", message: nil, preferredStyle: .actionSheet)
        shareActionSheet.addAction(UIAlertAction(title: "新浪微博", style: .default, handler: { _ in self.sinaWeiboSharing()}))
        shareActionSheet.addAction(UIAlertAction(title: "腾讯微博", style: .default, handler: { _ in self.tecentWeiboSharing()}))
        shareActionSheet.addAction(UIAlertAction(title: "facebook", style: .default, handler: { _ in self.facebookSharing()}))
        shareActionSheet.addAction(UIAlertAction(title: "twitter", style: .default, handler: { _ in self.twitterSharing()}))
        shareActionSheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(shareActionSheet, animated: true, completion: nil)

    }
    
    func getScreenShot(){
        let layer = infoContainerView.layer
        //let layer = UIApplication.sharedApplication().keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        screenShotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    //MARK: - different kinds of sharing
    func sinaWeiboSharing(){
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeSinaWeibo){
            let sinaWeboCompsor = SLComposeViewController(forServiceType: SLServiceTypeSinaWeibo)
            sinaWeboCompsor?.setInitialText("今天的锻炼目标，完成!")
            sinaWeboCompsor?.add(screenShotImage)
            present(sinaWeboCompsor!, animated: true, completion: nil)
        }
        
    }
    
    func tecentWeiboSharing(){
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTencentWeibo){
            let tecentWeboCompor = SLComposeViewController(forServiceType: SLServiceTypeTencentWeibo)
            tecentWeboCompor?.setInitialText("今天的锻炼目标，完成!")
            tecentWeboCompor?.add(screenShotImage)
            present(tecentWeboCompor!, animated: true, completion: nil)
        }
    }
    
    func facebookSharing(){
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let facebookCompor = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookCompor?.setInitialText("今天的锻炼目标，完成!")
            facebookCompor?.add(screenShotImage)
            present(facebookCompor!, animated: true, completion: nil)
        }
    }
    
    func twitterSharing(){
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter){
            let twitterCompor = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterCompor?.setInitialText("今天的锻炼目标，完成!")
            twitterCompor?.add(screenShotImage)
            present(twitterCompor!, animated: true, completion: nil)
        }
    }

    
    @IBAction func photoButtonPressed() {
        let alertController = UIAlertController(title: "Pick a photo", message: "Pick a photo from library or take a new photo", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "from library", style: .default, handler: { _ in
            self.choosePhotoFromLibrary()
        }))
        alertController.addAction(UIAlertAction(title: "new photo", style: .default, handler: { _ in
            self.performSegue(withIdentifier: TakePhotoSegueIdentifier, sender: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func choosePhotoFromLibrary(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true
            , completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            workout.image = image
            let iconImage = image.resizedImageWithBounds(cameraButton.layer.bounds.size)
            cameraButton.setImage(iconImage, for: UIControlState())
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    
    var workout: Jog = Jog(){
        didSet{
            workout.date = Date()
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
        if UIScreen.main.bounds.size.height == 480.0{
            
            for constraint in infoTitleLabel.superview!.constraints{
                
                if constraint.firstItem as? NSObject == infoTitleLabel && constraint.firstAttribute == .top{
                    constraint.constant -= 10
                }
            }
            for constraint in cameraButton.superview!.constraints{
                
                if constraint.firstItem as? NSObject == cameraButton && constraint.firstAttribute == .top{
                    constraint.constant -= 10
                }
            }
            
            for constraint in timeLabel.superview!.constraints{
                if constraint.firstItem as? NSObject == timeLabel && constraint.firstAttribute == .top{
                    constraint.constant -= 15
                }
            }
        }
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        managedContext = appdelegate.managedObjectContext
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: PhotoCaptureNotification.photoInfoNotificationName), object: nil, queue: OperationQueue.main) { (notification) in
            let image = (notification as NSNotification).userInfo!["photo"] as! UIImage
            self.workout.image = image
            let iconImage = image.resizedImageWithBounds(self.cameraButton.layer.bounds.size)
            self.cameraButton.setImage(iconImage, for: UIControlState())
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //将用于动画的控件的自动布局参数改变使的它们移出界面以准备动画
        for constraint in infoTitleLabel.superview!.constraints{
            
            if constraint.firstItem as? NSObject == infoTitleLabel && constraint.firstAttribute == .top{
                constraint.constant -= view.bounds.height/2
            }
        }
        for constraint in distanceAndStepSatckView.superview!.constraints{
            
            if constraint.firstItem as? NSObject == distanceAndStepSatckView && constraint.firstAttribute == .centerX{
                constraint.constant -= view.bounds.width
            }
        }
        for constraint in timeLabel.superview!.constraints{
            
            if constraint.firstItem as? NSObject == timeLabel && constraint.firstAttribute == .centerX{
                constraint.constant += view.bounds.width
            }
        }
        for constraint in discriptionLabel.superview!.constraints{
            
            if constraint.secondItem as? NSObject == discriptionLabel && constraint.firstAttribute == .bottom{
                constraint.constant -= view.bounds.height
            }
        }
        for constraint in infoContainerView.superview!.constraints{
            
            if constraint.firstItem as? NSObject == infoContainerView && constraint.firstAttribute == .height{
                constraint.constant -= view.bounds.height * constraint.multiplier
            }
        }
        
        //将照相机图标隐藏为动画做准备
        cameraButton.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //将被用于动画的界面元素的自动布局参数设回原值
        for constraint in infoTitleLabel.superview!.constraints{
            
            if constraint.firstItem as? NSObject == infoTitleLabel && constraint.firstAttribute == .top{
                constraint.constant += view.bounds.height/2
            }
        }
        for constraint in distanceAndStepSatckView.superview!.constraints{
            
            if constraint.firstItem as? NSObject == distanceAndStepSatckView && constraint.firstAttribute == .centerX{
                constraint.constant += view.bounds.width
            }
        }
        for constraint in timeLabel.superview!.constraints{
            
            if constraint.firstItem as? NSObject == timeLabel && constraint.firstAttribute == .centerX{
                constraint.constant -= view.bounds.width
            }
        }
        for constraint in discriptionLabel.superview!.constraints{
            
            if constraint.secondItem as? NSObject == discriptionLabel && constraint.firstAttribute == .bottom{
                constraint.constant += view.bounds.height
            }
        }
        for constraint in infoContainerView.superview!.constraints{
            
            if constraint.firstItem as? NSObject == infoContainerView && constraint.firstAttribute == .height{
                constraint.constant += view.bounds.height * constraint.multiplier
            }
        }

        //将控件移动回原处的动画
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 15, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
        //将照相机图标显示出来的动画
        UIView.animate(withDuration: 1.0, delay: 0.3, options: [], animations: {
            self.cameraButton.alpha = 1.0
            }, completion: nil)
        
        }
    
   }
