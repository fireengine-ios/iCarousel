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
    private lazy var activityManager = ActivityIndicatorManager()

    @IBOutlet private weak var premiumView: PremiumView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        output.onViewDidLoad(with: premiumView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
    
    // MARK: Utility methods
    private func setup() {
        activityManager.delegate = self
        setTitle(withString: output.title)
        
        let titleEdgeInsets = UIEdgeInsetsMake(13, 18, 13, 18)
        let description = TextConstants.useFollowingPremiumMembership
        premiumView.configure(with: output.headerTitle, price: "", description: description, types: PremiumListType.allTypes, titleEdgeInsets: titleEdgeInsets)
    }
    
}

// MARK: - PremiumViewInput
extension PremiumViewController: PremiumViewInput {
    func displayFeatureInfo(price: String?, description: String) {
        let titleEdgeInsets = UIEdgeInsetsMake(13, 18, 13, 18)
        premiumView.configure(with: output.headerTitle, price: price, description: description, types: PremiumListType.allTypes, titleEdgeInsets: titleEdgeInsets)
    }
}

// MARK: - ActivityIndicator
extension PremiumViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}
