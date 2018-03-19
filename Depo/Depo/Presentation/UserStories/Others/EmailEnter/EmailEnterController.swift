//
//  EmailEnterController.swift
//  Depo_LifeTech
//
//  Created by Bondar Yaroslav on 3/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class EmailEnterController: UIViewController, NibInit {
    
    deinit {
        print("- deint EmailEnterController")
    }
    
    @IBOutlet private var customizator: EmailEnterCustomizator!
    
//    @IBOutlet private weak var approveButton: UIButton!
    @IBOutlet private weak var emailTextField: UnderlineTextField!
    
    private lazy var attemptsCounter = SavingAttemptsCounter(limit: NumericConstants.emptyEmailUserCloseLimit, userDefaultsKey: "EmailSavingAttemptsCounter", limitHandler: {
        self.attemptsCounter.reset()
        AppConfigurator.logout()
    })
    
    var approveCancelHandler: VoidHandler? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func closeAnimated() {
        dismiss(animated: true, completion: {
            self.approveCancelHandler?()
        })
    }
    
    @IBAction private func actionApproveButton(_ sender: UIButton) {
        print("actionApproveButton")
        closeAnimated()
    }
    
    @IBAction private func actionCloseButton(_ sender: UIButton) {
        attemptsCounter.up()
        closeAnimated()
    }
}
