//
//  StepCounter.swift
//  joggers
//
//  Created by Long Baolin on 16/3/24.
//  Copyright © 2016年 Lintasty. All rights reserved.
//

import Foundation
import CoreMotion

protocol StepCountingDelegate {
    func didUpdateSteps(numberOfSteps: Int)
}

class StepCounter: NSObject {
    
    private var startTime: NSDate?
    private var endTime: NSDate!
    private var pedonmter: CMPedometer!
    lazy private var numberOfSteps = 0
    private var getSetpTimer:NSTimer?
    var delegate: StepCountingDelegate!
    private var shouldUpdateSteps = false
    
    
    func startStepCounting() {
        numberOfSteps = 0
        startTime = NSDate()
        shouldUpdateSteps = true
        startUpdateSteps()
    }
    
    func endStepCounting(){
        shouldUpdateSteps = false
        getSetpTimer?.invalidate()
    }
    
    func pause(){
        shouldUpdateSteps = false
    }
    
    func continueCounting(){
        shouldUpdateSteps = true
    }
    
    func resetToStart(){
        shouldUpdateSteps = false
        numberOfSteps = 0
        getSetpTimer?.invalidate()
        startTime = nil
    }
    private func startUpdateSteps(){
        getSetpTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(StepCounter.getNumberOfSteps), userInfo: nil, repeats: true)
    }
    
    @objc private func getNumberOfSteps(){
        
        getPedonmeterData()
        
        if shouldUpdateSteps{
            delegate?.didUpdateSteps(numberOfSteps)
        }
    }
    
    private func getPedonmeterData(){
        
        endTime = NSDate()
        pedonmter = CMPedometer()
        if CMPedometer.isStepCountingAvailable(){
            if startTime != nil{
            pedonmter.queryPedometerDataFromDate(startTime!, toDate: endTime, withHandler: { (data, error) in
                if error != nil{
                    print("\(error?.localizedDescription)")
                }else{
                    if data != nil{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.numberOfSteps = Int(data!.numberOfSteps)
                        })
                    }
                }
            })
            
        }
        }
    }
}