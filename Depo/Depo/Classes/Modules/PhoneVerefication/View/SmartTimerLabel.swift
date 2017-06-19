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
    private var displayedMinutes: Int = 0
    private var displayedSeconds: Int = 0
    let secondsInMinute: Int = 60
    private var timer: Timer?
    private var lifeLimit: Int = 0//timer Life time
    private var timerCycle: Int = 0//number of cycle
    var isDead: Bool = true
    func setupTimer(withTimeInterval timeInterval: Float = 1.0, timerLimit lifetime: Int = 120, clearAtTheEnd clear: Bool = false) {
        self.isDead = false
        self.lifeLimit = lifetime
        self.text = "0:00"
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval),
                                          target: self,
                                          selector: #selector(self.timerUpdate),
                                          userInfo: nil, repeats: true)
    }
    
    @objc private func timerUpdate() {
        self.timerCycle += 1
        self.setupTimerLabel()
        self.checkLifeSpent()
        
    }
    
    private func checkLifeSpent() {
        if self.timerCycle >= lifeLimit {
            self.isDead = true
            self.timerCycle = 0
            self.displayedMinutes = 0
            self.displayedSeconds = 0
            self.timer?.invalidate()
            self.delegate?.timerDidFinishRunning()
        }
    }
    
    private func setupTimerLabel() {

        self.displayedSeconds += 1
        var additionalCharacter = ""
        if self.timerCycle % 60 < 10 {
            additionalCharacter = "0"
        }
        if self.timerCycle % 60 == 0 {
            self.displayedMinutes += 1
            self.displayedSeconds = 0
        }

        self.text = String(displayedMinutes) + ":" + additionalCharacter + String(displayedSeconds)
    }
    
}
