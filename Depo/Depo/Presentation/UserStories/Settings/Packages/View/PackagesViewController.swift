//
//  PackagesPackagesViewController.swift
//  Depo
//
//  Created by Yaroslav Bondar on 20/09/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class PackagesViewController: UIViewController {
    var output: PackagesViewOutput!
    
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var promoView: PromoView!
    @IBOutlet var keyboardHideManager: KeyboardHideManager!
    
    private lazy var activityManager = ActivityIndicatorManager()
    
    private var plans = [SubscriptionPlan]() {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: TextConstants.packages)
        activityManager.delegate = self
        promoView.deleagte = self
        setupCollectionView()
        output.viewIsReady()
    }
    
    private func setupCollectionView() {
        collectionView.register(nibCell: SubscriptionPlanCollectionViewCell.self)
    }
}

// MARK: PackagesViewInput
extension PackagesViewController: PackagesViewInput {
    
    func reloadPackages() {
        plans = []
        output.viewIsReady()
    }
    
    func successedPromocode() {
        stopActivityIndicator()
        CustomPopUp.sharedInstance.showCustomSuccessAlert(withTitle: TextConstants.success, withText: TextConstants.promocodeSuccess, okButtonText: TextConstants.ok)
        
        promoView.endEditing(true)
        promoView.codeTextField.text = ""
        promoView.errorLabel.text = ""
        reloadPackages()
    }
    
    func show(promocodeError: String) {
        stopActivityIndicator()
        promoView.errorLabel.text = promocodeError
    }
    
    func display(error: ErrorResponse) {
        CustomPopUp.sharedInstance.showCustomInfoAlert(withTitle: TextConstants.errorAlert, withText: error.description, okButtonText: TextConstants.ok)
    }
    
    func display(subscriptionPlans array: [SubscriptionPlan]) {
        plans += array
    }
    
    func showActivateOfferAlert(for offer: OfferServiceResponse) {
        let bodyText = "\(offer.period ?? "") \(offer.price ?? 0)"
        
        let vc = DarkPopUpController.with(title: offer.name, message: bodyText, buttonTitle: TextConstants.purchase) { [weak self] vc in
            vc.close()
            self?.output.buy(offer: offer)
        }
        present(vc, animated: false, completion: nil)
    }
    
    func showSubTurkcellOpenAlert(with text: String) {
        let vc = DarkPopUpController.with(title: TextConstants.offersInfo, message: text, buttonTitle: TextConstants.offersOk)
        present(vc, animated: false, completion: nil)
    }
    
    func showCancelOfferAlert(with text: String) {
        let vc = DarkPopUpController.with(title: TextConstants.offersInfo, message: text, buttonTitle: TextConstants.offersOk)
        present(vc, animated: false, completion: nil)
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

// MARK: - ActivityIndicator
extension PackagesViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}

// MARK: - PromoViewDelegate
extension PackagesViewController: PromoViewDelegate {
    func promoView(_ promoView: PromoView, didPressApplyWithPromocode promocode: String) {
        startActivityIndicator()
        output.submit(promocode: promocode)
        keyboardHideManager.dismissKeyboard()
    }
}
