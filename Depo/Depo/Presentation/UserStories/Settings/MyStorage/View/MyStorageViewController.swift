//
//  MyStorageViewController.swift
//  Depo
//
//  Created by Raman Harhun on 11/27/18.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

final class MyStorageViewController: BaseViewController {
    
    //MARK: vars
    var output: MyStorageViewOutput!
    private lazy var activityManager = ActivityIndicatorManager()
    
    //MARK: IBOutlet
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var collectionView: ResizableCollectionView!
    
    @IBOutlet private weak var dividerView: UIView! {
        didSet {
            dividerView.backgroundColor = ColorConstants.photoCell
        }
    }

    @IBOutlet private weak var usageLabel: UILabel! {
        didSet {
            usageLabel.text = ""
            usageLabel.textColor = UIColor.lrTealish
            usageLabel.font = UIFont.TurkcellSaturaBolFont(size: 18)
        }
    }
    
    @IBOutlet private weak var packagesLabel: UILabel! {
        didSet {
            packagesLabel.text = TextConstants.packagesIHave
            packagesLabel.textColor = ColorConstants.darkText
            packagesLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        }
    }
    
    @IBOutlet private weak var percentageLabel: UILabel! {
        didSet {
            percentageLabel.text = String(format: TextConstants.usagePercentageTwoLines, 0)
            percentageLabel.numberOfLines = 0
            percentageLabel.textAlignment = .center
            percentageLabel.textColor = UIColor.lrTealish
            percentageLabel.font = UIFont.TurkcellSaturaBolFont(size: 20)
        }
    }
    
    @IBOutlet private weak var storageUsageProgressView: CircleProgressView! {
        didSet {
            storageUsageProgressView.backColor = UIColor.lrTealish.withAlphaComponent(0.25)
            storageUsageProgressView.progressColor = UIColor.lrTealish
            storageUsageProgressView.backWidth = 8
            storageUsageProgressView.progressWidth = 8
            storageUsageProgressView.layoutIfNeeded()
            storageUsageProgressView.set(progress: 0, withAnimation: false)
        }
    }
    
    private lazy var restoreButton = UIBarButtonItem(image: UIImage(named: "refresh_icon"), style: .plain, target: self, action: #selector(restorePurhases))
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        output.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        output.viewDidAppear()
    }
    
    //MARK: UtilityMethods
    private func setup() {
        setTitle(withString: output.title)

        setupCollectionView()
        activityManager.delegate = self
        automaticallyAdjustsScrollViewInsets = false
    }
    
    private func setupCollectionView() {
        collectionView.register(nibCell: SubscriptionPlanCollectionViewCell.self)
    }
}

// MARK: - MyStorageViewInput
extension MyStorageViewController: MyStorageViewInput {
    func configureProgress(with full: Int64, used: Int64) {
        let usage = CGFloat(used) / CGFloat(full)
        
        storageUsageProgressView.set(progress: usage, withAnimation: true)
        
        percentageLabel.text = String(format: TextConstants.usagePercentageTwoLines, (usage * 100).rounded(.toNearestOrAwayFromZero))
        
        usageLabel.text = String(format: TextConstants.packageApplePrice, used.bytesString, full.bytesString)
    }
    
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    func showRestoreButton() {
        //IF THE USER NON CELL USER
        navigationItem.rightBarButtonItem = restoreButton
    }
    
    @objc private func restorePurhases() {
        startActivityIndicator()
        output.restorePurchasesPressed()
    }
}

//MARK: UICollectionViewDataSource
extension MyStorageViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return output.displayableOffers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: SubscriptionPlanCollectionViewCell.self, for: indexPath)
        cell.delegate = self
        cell.indexPath = indexPath
        cell.configure(with: output.displayableOffers[indexPath.row], accountType: output.accountType)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if Device.isIpad {
            ///https://github.com/wordpress-mobile/WordPress-iOS/issues/10354
            ///seems like this bug may occur on iOS 12+ when it returns negative value
            return CGSize(width: max(collectionView.frame.width / 2 - NumericConstants.iPadPackageSumInset, 0), height: NumericConstants.heightForPackageCell)
        } else {
            return CGSize(width: max(collectionView.frame.width / 2 - NumericConstants.packageSumInset, 0), height: NumericConstants.heightForPackageCell)
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyStorageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Device.isIpad ? 28 : 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Device.isIpad ? 28 : 10
    }
}

// MARK: - SubscriptionPlanCellDelegate
extension MyStorageViewController: SubscriptionPlanCellDelegate {
    func didPressSubscriptionPlanButton(at indexPath: IndexPath) {
        guard let plan = output?.displayableOffers[indexPath.row] else { return }
        
        if let tag = MenloworksSubscriptionStorage(rawValue: plan.name) {
            MenloworksAppEvents.onSubscriptionClicked(tag)
        }
        
        output?.didPressOn(plan: plan, planIndex: indexPath.row)
    }
}

// MARK: - ActivityIndicator
extension MyStorageViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }

    func stopActivityIndicator() {
        activityManager.stop()
    }
}
