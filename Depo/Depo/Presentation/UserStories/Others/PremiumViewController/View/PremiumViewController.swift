//
//  PremiumViewController.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PremiumViewController: BaseViewController {
    
    var output: PremiumViewOutput!
    
    @IBOutlet private weak var premiumView: PremiumView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        output.onViewDidLoad(with: premiumView)
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    // MARK: Utility methods
    private func setup() {
        setTitle(withString: output.title)
        
        let titleEdgeInsets = UIEdgeInsetsMake(13, 18, 13, 18)
        premiumView.configure(with: output.headerTitle, price: "30 $", types: PremiumListType.allTypes, titleEdgeInsets: titleEdgeInsets)
    }
    
}

// MARK: - PremiumViewInput
extension PremiumViewController: PremiumViewInput {
}
