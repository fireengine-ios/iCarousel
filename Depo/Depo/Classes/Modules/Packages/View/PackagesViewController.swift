//
//  PackagesPackagesViewController.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PackagesViewController: UIViewController {
    
    private var plans = [SubscriptionPlan]() {
        didSet {
            collectionView.reloadData()
        }
    }

    @IBOutlet weak private var collectionView: UICollectionView!
    
    var output: PackagesViewOutput!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        output.viewIsReady()
    }
    
    private func setupCollectionView() {
        collectionView.register(nibCell: SubscriptionPlanCollectionViewCell.self)
    }
}

// MARK: PackagesViewInput
extension PackagesViewController: PackagesViewInput {
    
    func display(error: ErrorResponse) {
        print(error.description)
    }
    
    func display(subscriptionPlans array: [SubscriptionPlan]) {
        plans += array
    }
    
    func showActivateOfferAlert(for offer: OfferServiceResponse) {
        let bodyText = "\(offer.period ?? "") \(offer.price ?? 0)"
        let alertVC = UIAlertController(title: offer.name, message: bodyText, preferredStyle: .alert)
        alertVC.view.tintColor = UIColor.lrTealish
        
        let cancelAction = UIAlertAction(title: TextConstants.offersCancel, style: .cancel, handler: nil)
        let buyAction = UIAlertAction(title: TextConstants.offersBuy, style: .default) { action in
            self.output.buy(offer: offer)
        }
        
        alertVC.addAction(buyAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func showCancelOfferAlert(for accountType: AccountType) {
        let message: String
        
        switch accountType {
        case .turkcell:
            message = TextConstants.offersTurkcellCancel
        case .subTurkcell:
            message = TextConstants.offersSubTurkcellCancel
        case .all:
            return
        }
        
        let alertVC = UIAlertController(title: TextConstants.offersInfo, message: message, preferredStyle: .alert)
        alertVC.view.tintColor = UIColor.lrTealish
        
        let okAction = UIAlertAction(title: TextConstants.offersOk, style: .cancel, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func showCancelOfferApple() {
        let alertVC = UIAlertController(title: TextConstants.offersInfo, message: TextConstants.offersAllCancel, preferredStyle: .alert)
        alertVC.view.tintColor = UIColor.lrTealish
        
        let okAction = UIAlertAction(title: TextConstants.offersOk, style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: TextConstants.offersSettings, style: .default) { _ in
            UIApplication.shared.openSettings()
        }
        
        alertVC.addAction(settingsAction)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDataSource
extension PackagesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plans.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: SubscriptionPlanCollectionViewCell.self, for: indexPath)
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configure(with: plans[indexPath.item])
        return cell
    }
}

// MARK: SubscriptionPlanCellDelegate
extension PackagesViewController: SubscriptionPlanCellDelegate {
    func didPressSubscriptionPlanButton(at indexPath: IndexPath) {
        output.didPressOn(plan: plans[indexPath.row])
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension PackagesViewController: UICollectionViewDelegateFlowLayout {
}

// MARK: UICollectionViewDelegate
extension PackagesViewController: UICollectionViewDelegate {
}
