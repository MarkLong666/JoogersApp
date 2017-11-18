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
    func didUpdateSteps(_ numberOfSteps: Int)
}

class StepCounter: NSObject {
    
    fileprivate var startTime: Date?
    fileprivate var endTime: Date!
    fileprivate var pedonmter: CMPedometer!
    lazy fileprivate var numberOfSteps = 0
    fileprivate var getSetpTimer:Timer?
    var delegate: StepCountingDelegate!
    fileprivate var shouldUpdateSteps = false
    
    
    func startStepCounting() {
        numberOfSteps = 0
        startTime = Date()
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
    fileprivate func startUpdateSteps(){
        getSetpTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(StepCounter.getNumberOfSteps), userInfo: nil, repeats: true)
    }
    
    @objc fileprivate func getNumberOfSteps(){
        
        getPedonmeterData()
        
        if shouldUpdateSteps{
            delegate?.didUpdateSteps(numberOfSteps)
        }
    }
    
    fileprivate func getPedonmeterData(){
        
        endTime = Date()
        pedonmter = CMPedometer()
        if CMPedometer.isStepCountingAvailable(){
            if startTime != nil{
            pedonmter.queryPedometerData(from: startTime!, to: endTime, withHandler: { (data, error) in
                if error != nil{
                    print(error!.localizedDescription)
                }else{
                    if data != nil{
                        DispatchQueue.main.async(execute: {
                            self.numberOfSteps = Int(data!.numberOfSteps)
                        })
                    }
                }
            })
            
        }
        }
    }
}
