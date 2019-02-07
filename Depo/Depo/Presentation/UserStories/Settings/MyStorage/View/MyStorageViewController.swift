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
    @IBOutlet private weak var storageUsageTextView: UITextView!
    @IBOutlet weak var collectionView: ResizableCollectionView!
    @IBOutlet private weak var storageUsageProgressView: RoundedProgressView! {
        didSet {
            storageUsageProgressView.trackTintColor = ColorConstants.lightGrayColor
            storageUsageProgressView.progressTintColor = ColorConstants.greenColor
            storageUsageProgressView.progress = 0
        }
    }
    
    private lazy var restoreButton = UIBarButtonItem(image: UIImage(named: "refresh_icon"), style: .plain, target: self, action: #selector(restorePurhases))
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        output.viewDidLoad()
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
    func configureProgress(with full: Int64, left: Int64) {
        storageUsageProgressView.progress = Float(left) / Float(full)
        
        let storageString = String(format: TextConstants.usageInfoBytesRemained, left.bytesString, full.bytesString)
        
        //TODO: - think how to change this code for RTL languages
        
//        guard let lastWord = storageString.lastIndex(of: " ") else { return }
//        let lastWordLocation = storageString.distance(from: storageString.startIndex,
//                                                      to: lastWord)
//        let lastWordLength = storageString.distance(from: lastWord,
//                                                    to: storageString.endIndex)
//        let range = NSRange(location: lastWordLocation, length: lastWordLength)
        
        let attributedString = NSMutableAttributedString(string: storageString, attributes: [
            .font: UIFont.TurkcellSaturaBolFont(size: 20),
            .foregroundColor: ColorConstants.textGrayColor,
            .kern: 0.0
            ])
//        attributedString.addAttribute(.font, value: UIFont.TurkcellSaturaMedFont(size: 20), range: range)
        
        storageUsageTextView.attributedText = attributedString
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
            return CGSize(width: collectionView.frame.width / 2 - NumericConstants.iPadPackageSumInset, height: NumericConstants.heightForPackageCell)
        } else {
            return CGSize(width: collectionView.frame.width / 2 - NumericConstants.packageSumInset, height: NumericConstants.heightForPackageCell)
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
