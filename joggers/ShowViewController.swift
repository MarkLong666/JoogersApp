//
//  ShowViewController.swift
//  joggers
//
//  Created by Long Baolin on 16/4/18.
//  Copyright © 2016年 Lintasty. All rights reserved.
//

import UIKit

class ShowViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image:UIImage!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        imageView.image = image
    }


    @IBAction func reCapture() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func OKPressed() {
        dismiss(animated: false, completion: nil)
        let notification = Notification(name: Notification.Name(rawValue: PhotoCaptureNotification.photoChoosedNotificationName), object: self)
        NotificationCenter.default.post(notification)
        let photoInfoNotification = Notification(name: Notification.Name(rawValue: PhotoCaptureNotification.photoInfoNotificationName), object: self, userInfo: ["photo": image])
        NotificationCenter.default.post(photoInfoNotification)
    }

}
