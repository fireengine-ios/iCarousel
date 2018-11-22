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
    
    var output: LeavePremiumViewOutput!
        
    @IBOutlet private weak var leavePremiumView: LeavePremiumView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        output.onViewDidLoad(with: leavePremiumView)
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    // MARK: Utility methods
    private func setup() {
        setTitle(withString: TextConstants.lifeboxPremium)
        
        leavePremiumView.configure(with: "30 $/month", types: PremiumListType.allTypes)
    }
    
}

// MARK: - LeavePremiumViewInput
extension LeavePremiumViewController: LeavePremiumViewInput {
}
