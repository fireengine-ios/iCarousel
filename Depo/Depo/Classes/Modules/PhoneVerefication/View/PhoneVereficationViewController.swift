//
//  PhoneVereficationPhoneVereficationViewController.swift
//  Depo
//
//  Created by AlexanderP on 14/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PhoneVereficationViewController: UIViewController, PhoneVereficationViewInput {

    var output: PhoneVereficationViewOutput!

    @IBOutlet weak var codeVereficationField: UITextField!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var resendButton: UIButton!
    
    var timer: Timer?
    var timerCycle: Int = 0
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = TextConstants.registerTitle
        output.viewIsReady()
        self.setupTimer()
    }
    
    //test-----
    private func setupTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerUpdate), userInfo: nil, repeats: true)
    }
    @objc private func timerUpdate() {
        debugPrint("timer here")
        self.timerCycle += 1
//        let <#name#> = <#value#>
        self.setupTimerLabel()
//        self.timerLabel.text = ""
        if self.timerCycle >= 10 {
            self.timerLabel.text = "2:00"
            debugPrint("timer invalid")
            self.timerCycle = 0
            self.timer?.invalidate()
            self.resendButton.isHidden = false
            self.resendButton.isEnabled = true
        }
    }
    
    private func setupTimerLabel() {
        
    }
    //----test
    
    // MARK: PhoneVereficationViewInput
    func setupInitialState() {
    }
    
    @IBAction func ResendCode(_ sender: Any) {
        self.resendButton.isHidden = true
        self.resendButton.isEnabled = false
        self.setupTimer()
    }
    
}
