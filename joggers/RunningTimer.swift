//
//  RunningTimer.swift
//  joggers
//
//  Created by Long Baolin on 16/3/15.
//  Copyright © 2016年 Lintasty. All rights reserved.
//

import Foundation

class RunningTimer: NSObject{
    
    //传入的视图上的label
    fileprivate var timeLabel: UILabel!
    
    //计时器
    fileprivate var timer: Timer?
    
    //开始和结束时间列表
    fileprivate lazy var startTimes = [Date]()
    fileprivate lazy var endTimes = [Date]()
    
    //以秒计的计时数字
    fileprivate var timeNumber = 0{
        didSet{
            timeString = getTimeStringFromSecond(timeNumber)
        }
    }
    
        
    //用于显示在视图上的时间字符串
    internal fileprivate(set) var timeString = "00:00:00"{
        didSet{
            timeLabel.text = timeString
        }
    }

    //自定义初始化方法
    init(timeLabel: UILabel){
        self.timeLabel = timeLabel
        timeLabel.text = timeString
    }
    
    fileprivate func timeCount(){
        print("Start: " + "\(startTimes)")
        print("End:" + "\(endTimes)")
            if startTimes.count == 1 {
                let currentTime = Date()
                timeNumber = Int(CFDateGetTimeIntervalSinceDate(currentTime as CFDate!, startTimes[0] as CFDate!))
            }else{
                if startTimes.count - endTimes.count == 1 {
                    endTimes.append(Date())
                }
                let index = startTimes.count - 1
                endTimes[index] = Date()
                var timeCount = 0
                for startTime in startTimes{
                    timeCount += Int(CFDateGetTimeIntervalSinceDate(endTimes[startTimes.index(of: startTime)!] as CFDate!,startTime as CFDate!))
                }
                timeNumber = timeCount
            }
        
    }
    
    @objc fileprivate func count(){
        timeCount()
    }

    //计时开始
    func timingStart(){
        startTimes.append(Date())
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.count), userInfo: nil, repeats: true)
        
    }
    
    //暂停计时
    func timingPause(){
        endTimes.append(Date())
        timer?.invalidate()
    }
    
    //暂停后继续计时
    func timingContinue(){
        timingStart()
    }
    
    //重置Timer
    func resertToStart() {
        startTimes = []
        endTimes = []
        timer?.invalidate()
        timeNumber = 0
    }
    //获得当前运动时间
    func getCurrentRunningTime() -> Int {
        return timeNumber
    }
    
    
    
}
