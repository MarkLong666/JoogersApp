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
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func OKPressed() {
        dismissViewControllerAnimated(false, completion: nil)
        let notification = NSNotification(name: PhotoCaptureNotification.photoChoosedNotificationName, object: self)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        let photoInfoNotification = NSNotification(name: PhotoCaptureNotification.photoInfoNotificationName, object: self, userInfo: ["photo": image])
        NSNotificationCenter.defaultCenter().postNotification(photoInfoNotification)
    }

}
