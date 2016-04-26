//
//  FunctionUtil.swift
//  joggers
//
//  Created by Long Baolin on 16/3/17.
//  Copyright © 2016年 Lintasty. All rights reserved.
//

import Foundation

//自定义的延迟时间以延迟执行某些指令的方法
func delay(seconds seconds: Double, completion: ()->()){
    
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ) )
    
    dispatch_after(popTime, dispatch_get_main_queue()){
        completion()
    }
}

//从以秒计时的时间里获得表示时间的字符串用于显示
func getTimeStringFromSecond(seconds: Int) -> String {
    
    let secondNumber = seconds % 60
    let minuteNumber = (seconds / 60) % 60
    let hourNumber = (seconds / (60*60)) % 24
    
    let secondText = secondNumber < 10 ? "0\(secondNumber)" : "\(secondNumber)"
    let minuteText = minuteNumber < 10 ? "0\(minuteNumber)" : "\(minuteNumber)"
    let hourText = hourNumber < 10 ? "0\(hourNumber)" : "\(hourNumber)"
    
    return "\(hourText):\(minuteText):\(secondText)"
}

//某些特殊颜色
struct MySpecialColors {
    
    static let starbucksBrown = UIColor(red: 169/255, green: 142/255, blue: 103/255, alpha: 1)
    static let specialWrite = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1)
    static let specialRed = UIColor(red: 232/255, green: 69/255, blue: 126/255, alpha: 1)
}

//用于拍照片的一些通知名称
struct PhotoCaptureNotification{
    static let photoChoosedNotificationName = "photoCaptureControllersPhotoChoosed"
    static let photoInfoNotificationName = "photoCapturePhotoInfo"
}

//用于改变图片大小
extension UIImage {
    func resizedImageWithBounds(bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        drawInRect(CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}


