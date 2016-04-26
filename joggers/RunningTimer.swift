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
    private var timeLabel: UILabel!
    
    //计时器
    private var timer: NSTimer?
    
    //开始和结束时间列表
    lazy private var startTimes = [NSDate]()
    lazy private var endTimes = [NSDate]()
    
    //以秒计的计时数字
    private var timeNumber = 0{
        didSet{
            timeString = getTimeStringFromSecond(timeNumber)
        }
    }
    
        
    //用于显示在视图上的时间字符串
    internal private(set) var timeString = "00:00:00"{
        didSet{
            timeLabel.text = timeString
        }
    }

    //自定义初始化方法
    init(timeLabel: UILabel){
        self.timeLabel = timeLabel
        timeLabel.text = timeString
    }
    
    private func timeCount(){
        print("Start: " + "\(startTimes)")
        print("End:" + "\(endTimes)")
            if startTimes.count == 1 {
                let currentTime = NSDate()
                timeNumber = Int(CFDateGetTimeIntervalSinceDate(currentTime, startTimes[0]))
            }else{
                if startTimes.count - endTimes.count == 1 {
                    endTimes.append(NSDate())
                }
                let index = startTimes.count - 1
                endTimes[index] = NSDate()
                var timeCount = 0
                for startTime in startTimes{
                    timeCount += Int(CFDateGetTimeIntervalSinceDate(endTimes[startTimes.indexOf(startTime)!],startTime))
                }
                timeNumber = timeCount
            }
        
    }
    
    @objc private func count(){
        timeCount()
    }

    //计时开始
    func timingStart(){
        startTimes.append(NSDate())
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(self.count), userInfo: nil, repeats: true)
        
    }
    
    //暂停计时
    func timingPause(){
        endTimes.append(NSDate())
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