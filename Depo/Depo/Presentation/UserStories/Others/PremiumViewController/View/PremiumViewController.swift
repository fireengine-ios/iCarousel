//
//  PremiumViewController.swift
//  Depo_LifeTech
//
//  Created by Harbros 3 on 11/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

final class PremiumViewController: BaseViewController, NibInit {
    
    var output: PremiumViewOutput!
    private lazy var activityManager = ActivityIndicatorManager()

    private lazy var premiumView: BecomePremiumView = {
        let premiumView = BecomePremiumView.initFromNib()
        view.addSubview(premiumView)
        premiumView.translatesAutoresizingMaskIntoConstraints = false
        premiumView.pinToSuperviewEdges()
        premiumView.isHidden = true
        return premiumView
    }()
    
    //MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        activityManager.delegate = self
        setTitle(withString: TextConstants.becomePremiumNavBarTitle)
        
        output.onViewDidLoad(with: premiumView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
    }
}

// MARK: - PremiumViewInput
extension PremiumViewController: PremiumViewInput {
    func showPaycellProcess(with cpcmOfferId: Int) {
        let controller = PaycellViewController.create(with: cpcmOfferId) { result in
            switch result {
            case .success():
                UIApplication.showSuccessAlert(message: TextConstants.successfullyPurchased)
            case .failed(_):
                UIApplication.showErrorAlert(message: TextConstants.errorUnknown)
            }
        }
        RouterVC().pushViewController(viewController: controller)
    }
    
    func displayOffers(_ package: PackageOffer) {
        let plans = package.offers.sorted(by: { !$0.isRecommended && $1.isRecommended })
        premiumView.configure(with: plans)
        premiumView.isHidden = false
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
