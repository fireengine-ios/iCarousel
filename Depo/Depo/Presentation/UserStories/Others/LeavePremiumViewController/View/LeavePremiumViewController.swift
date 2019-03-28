//
//  LeavePremiumViewController.swift
//  Depo
//
//  Created by Harbros 3 on 11/21/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

import UIKit

final class LeavePremiumViewController: BaseViewController {
        
    @IBOutlet private weak var leavePremiumView: LeavePremiumView!
    
    var output: LeavePremiumViewOutput!
    private lazy var activityManager = ActivityIndicatorManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        activityManager.delegate = self
        
        output.onViewDidLoad(with: leavePremiumView)
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    // MARK: Utility methods
    private func setup() {
        setTitle(withString: output.title)
        
        leavePremiumView.configure(with: "", type: output.controllerType, hideButton: true)
    }
    
}

// MARK: - LeavePremiumViewInput
extension LeavePremiumViewController: LeavePremiumViewInput {
    func display(price: String, hideLeaveButton: Bool) {
        leavePremiumView.configure(with: price, type: output.controllerType, hideButton: hideLeaveButton)
    }
}
