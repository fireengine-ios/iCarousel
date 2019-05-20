//
//  TimerLabel.swift
//  Depo
//
//  Created by Aleksandr on 6/15/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol SmartTimerLabelDelegate: class {
    func timerDidFinishRunning()
}

class SmartTimerLabel: UILabel {
    
    weak var delegate: SmartTimerLabelDelegate?
    
    private var timer: Timer?
    
    //timer Life time
    private var lifeLimit: Int = 0
    
    //number of cycle
    private var timerCycle: Int = 0
    
    var isDead: Bool = true
    var isShowMessageWithDropTimer: Bool = true
    
    var startDate: Date?
    
    func setupTimer(withTimeInterval timeInterval: Float = 1.0, timerLimit lifetime: Int) {
        stopTimer()
        isDead = false
        lifeLimit = lifetime
        timerCycle = 0
        stopTimer()
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval),
                                          target: self,
                                          selector: #selector(self.timerUpdate),
                                          userInfo: nil, repeats: true)
        setupTimerLabel()
        startDate = Date()
        setupObserver()
    }
    
    func dropTimer() {
        isShowMessageWithDropTimer = false
        timerCycle = lifeLimit   
    }
    
    private var notificationToken: NSObjectProtocol?
    
    private func setupObserver() {
         notificationToken = NotificationCenter.default.addObserver(forName: .UIApplicationWillEnterForeground, object: nil, queue: .main) { [weak self] _ in
            guard let `self` = self, let startDateUnwraped = self.startDate else {
                return
            }
            let currentDate = Date()
            
            let timeIntervalFromStartCurrentDate = currentDate.timeIntervalSince(startDateUnwraped)
            if Int(timeIntervalFromStartCurrentDate) > self.lifeLimit {
                self.timerCycle = self.lifeLimit
                return
            }
            self.timerCycle = Int(timeIntervalFromStartCurrentDate)
            
        }
    }
    
    deinit {
        if let notificationToken = notificationToken {
            NotificationCenter.default.removeObserver(notificationToken)
        }
    }
    
    @objc private func timerUpdate() {
        timerCycle += 1
        setupTimerLabel()
        checkLifeSpent()
    }
    
    private func stopTimer() {
        guard let curTimer = timer else {
            return
        }
        if curTimer.isValid {
            curTimer.invalidate()
            timer = nil
        }
    }
    
    private func checkLifeSpent() {
        if timerCycle >= lifeLimit {
           isDead = true
           stopTimer()
           delegate?.timerDidFinishRunning()
        }
    }
    
    private func setupTimerLabel() {
        var spendTime = lifeLimit - timerCycle
        if spendTime < 0 {
            spendTime = 0
        }
        let min = Int(spendTime) / 60
        let sec = Int(spendTime) % 60
        text = String(format: "%02i:%02i", min, sec)
    }
}
