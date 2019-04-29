//
//  UsageInfoViewController.swift
//  Depo
//
//  Created by Maksim Rahleev on 12.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

final class UsageInfoViewController: ViewController {
    var output: UsageInfoViewOutput!
    
    //MARK: IBOutlet
    @IBOutlet private weak var cardView: UIView! {
        didSet {
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = NumericConstants.usageInfoCardCornerRadius
            cardView.layer.shadowRadius = NumericConstants.usageInfoCardShadowRadius
            cardView.layer.shadowOpacity = NumericConstants.usageInfoCardShadowOpacity
            cardView.layer.shadowOffset = .zero
            cardView.layer.shadowColor = UIColor.black
                .withAlphaComponent(0.2)
                .cgColor
        }
    }
    
    @IBOutlet private weak var cardTitleLabel: UILabel! {
        didSet {
            cardTitleLabel.text = TextConstants.myStorage
            cardTitleLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
            cardTitleLabel.textColor = UIColor.lrTealish
        }
    }
    
    @IBOutlet private weak var cardDividerView: UIView! {
        didSet {
            cardDividerView.backgroundColor = ColorConstants.photoCell
        }
    }

    @IBOutlet private weak var photoUsageInfoView: MediaUsageInfoView!
    @IBOutlet private weak var videoUsageInfoView: MediaUsageInfoView!
    @IBOutlet private weak var musicUsageInfoView: MediaUsageInfoView!
    @IBOutlet private weak var docsUsageInfoView: MediaUsageInfoView!
    
    @IBOutlet private weak var circleProgressView: CircleProgressView! {
        didSet {
            circleProgressView.backWidth = NumericConstants.usageInfoProgressWidth
            circleProgressView.progressWidth = NumericConstants.usageInfoProgressWidth
            circleProgressView.progressRatio = 0.0
            circleProgressView.progressColor = .lrTealish
            circleProgressView.backColor = UIColor.lrTealish
                .withAlphaComponent(NumericConstants.progressViewBackgroundColorAlpha)
        }
    }
    
    @IBOutlet private weak var usagePercentageLabel: UILabel! {
        didSet {
            usagePercentageLabel.text = String(format: TextConstants.usagePercentageTwoLines, 0)
            usagePercentageLabel.textAlignment = .center
            usagePercentageLabel.numberOfLines = 0
            usagePercentageLabel.textColor = UIColor.lrTealish
            usagePercentageLabel.font = UIFont.TurkcellSaturaBolFont(size: 20)
        }
    }
    
    @IBOutlet private weak var wholeStorageDetailLabel: UILabel! {
        didSet {
            let zero = Int64(0).bytesString
            wholeStorageDetailLabel.text = String(format: TextConstants.usedAndLeftSpace, zero, zero)
            wholeStorageDetailLabel.numberOfLines = 0
            wholeStorageDetailLabel.textColor = UIColor.lrTealish
            wholeStorageDetailLabel.font = UIFont.TurkcellSaturaMedFont(size: 18)
        }
    }
    
    @IBOutlet private weak var upgradeButton: RoundedInsetsButton! {
        didSet {
            upgradeButton.backgroundColor = UIColor.lrTealish
            upgradeButton.setTitleColor(.white, for: .normal)
            upgradeButton.setTitle(TextConstants.fullQuotaSmallPopUpSecondButtonTitle, for: .normal)
            upgradeButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 14)
            upgradeButton.insets = UIEdgeInsets(top: 2, left: 16, bottom: 2, right: 16 )
        }
    }
    
    @IBOutlet weak var myDataUsageLabel: UILabel! {
        didSet {
            myDataUsageLabel.text = TextConstants.myUsageStorage
            myDataUsageLabel.textColor = UIColor.lrTealish
            myDataUsageLabel.font = UIFont.TurkcellSaturaMedFont(size: 18)
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.isPagingEnabled = true
            collectionView.allowsSelection = false
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
            }
        }
    }
    
    @IBOutlet weak var collectionViewHeightAnchor: NSLayoutConstraint!
    
    @IBOutlet private weak var pageControl: UIPageControl! {
        didSet {
            pageControl.currentPage = 0
            pageControl.hidesForSinglePage = true
            pageControl.isUserInteractionEnabled = false
            pageControl.currentPageIndicatorTintColor = UIColor.lrTealish
            pageControl.pageIndicatorTintColor = UIColor.lrTealish.withAlphaComponent(0.25)
        }
    }
    
    //MARK: Vars
    private var internetDataUsages: [InternetDataUsage] = [] {
        didSet {
            let isNeedHide = internetDataUsages.count == 0
            myDataUsageLabel.isHidden = isNeedHide
            collectionView.isHidden = isNeedHide
        }
    }
    
    private static let constantForCell: CGFloat = 28
    
    //MARK: lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupDesign()
        output.viewWillAppear()
    }
    
    //MARK: IBAction
    @IBAction func actionUpgradeButton(_ sender: UIButton) {
        output.upgradeButtonPressed(with: navigationController)
    }
    
    //MARK: Utility Methods
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(nibCell: InternetDataUsageCollectionViewCell.self)
    }

    private func setupDesign() {
        myDataUsageLabel.isHidden = true
        collectionView.isHidden = true
        
        let zero: Int = 0
        let zeroBytes: Int64 = 0
        photoUsageInfoView.configure(type: .photo, count: zero, volume: zeroBytes)
        musicUsageInfoView.configure(type: .music, count: zero, volume: zeroBytes)
        videoUsageInfoView.configure(type: .video, count: zero, volume: zeroBytes)
        docsUsageInfoView.configure(type: .docs, count: zero, volume: zeroBytes)
        
        circleProgressView.layoutIfNeeded()
        setTitle(withString: TextConstants.settingsViewCellUsageInfo)
    }
    
    ///This method need to calculate height for collectionView.
    ///It's need to make dynamic cells and we use highest cell as hneight for collectionView
    private func calculateHeightForCollectionView(with models: [InternetDataUsage]) {
        var biggerHeight: CGFloat = 0
        
        let commonWidth = collectionView.frame.width
        
        models.forEach { model in
            var cellHeight = UsageInfoViewController.constantForCell
            
            let usedVolume: CGFloat
            if let remaining = model.remaining, let total = model.total {
                usedVolume = CGFloat((1 - (remaining / total)) * 100)
            } else {
                usedVolume = 0
            }
            
            let textHeight: CGFloat = 25
            let widthForName = commonWidth - String(format: TextConstants.usagePercentage, usedVolume.rounded(.toNearestOrAwayFromZero))
                .width(for: textHeight, font: .TurkcellSaturaDemFont(size: 16))
            
            cellHeight += model.offerName?
                .height(for: widthForName, font: .TurkcellSaturaMedFont(size: 18)) ?? 0
            
            cellHeight += String(format: TextConstants.packageSpaceDetails, model.usedString, model.totalString)
                .height(for: commonWidth, font: UIFont.TurkcellSaturaRegFont(size: 18))

            if let dateString = model.expiryDate?.getDateInFormat(format: "dd MMM YYYY") {
                cellHeight += String(format: TextConstants.renewDate, dateString)
                    .height(for: commonWidth, font: UIFont.TurkcellSaturaRegFont(size: 14))
            }
            
            biggerHeight = max(biggerHeight, cellHeight)
        }
        
        collectionViewHeightAnchor.constant = biggerHeight
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
}

//MARK: - UsageInfoViewInput
extension UsageInfoViewController: UsageInfoViewInput {
    func display(usage: UsageResponse) {
        photoUsageInfoView.configure(type: .photo, count: usage.imageCount, volume: usage.imageUsage)
        videoUsageInfoView.configure(type: .video, count: usage.videoCount, volume: usage.videoUsage)
        musicUsageInfoView.configure(type: .music, count: usage.audioCount, volume: usage.audioUsage)
        docsUsageInfoView.configure(type: .docs, count: usage.othersCount, volume: usage.othersUsage)
        
        guard let quotaBytes = usage.quotaBytes, let usedBytes = usage.usedBytes else {
            return
        }
        
        wholeStorageDetailLabel.text = String(format: TextConstants.usedAndLeftSpace,
                                    usedBytes.bytesString,
                                    quotaBytes.bytesString)
        
        let usagePercentage = CGFloat(usedBytes) / CGFloat(quotaBytes)
        circleProgressView.set(progress: usagePercentage,
                               withAnimation: false)
        
        let percentage = (usagePercentage  * 100).rounded(.toNearestOrAwayFromZero)
        usagePercentageLabel.text = String(format: TextConstants.usagePercentageTwoLines, percentage)

        self.internetDataUsages = usage.internetDataUsage
        calculateHeightForCollectionView(with: self.internetDataUsages)
        
        ///needs to redraw progress view
        circleProgressView.layoutIfNeeded()
        
        collectionView.reloadData()
    }
    
    func display(error: ErrorResponse) {
        UIApplication.showErrorAlert(message: error.description)
    }
    
}

//MARK: - UICollectionViewDataSource
extension UsageInfoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = internetDataUsages.count
        return internetDataUsages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: InternetDataUsageCollectionViewCell.self, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? InternetDataUsageCollectionViewCell, let model = internetDataUsages[safe: indexPath.row] else {
            return
        }
        
        cell.configureWith(model: model, indexPath: indexPath)
    }
    
}

//MARK: - UICollectionViewDelegateFlowLayout
extension UsageInfoViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.frame.height
        let cellWidth = collectionView.frame.width
        ///https://github.com/wordpress-mobile/WordPress-iOS/issues/10354
        ///seems like this bug may occur on iOS 12+ when it returns negative value
        return CGSize(width: max(cellWidth, 0), height: max(cellHeight, 0))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return NumericConstants.usageInfoCollectionViewCellsOffset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return NumericConstants.usageInfoCollectionViewCellsOffset
    }
}

//MARK: - UICollectionViewDelegate
extension UsageInfoViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let cell = self.collectionView.visibleCells.first, let indexPath = self.collectionView.indexPath(for: cell) {
            self.pageControl.currentPage = indexPath.row
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate,  let cell = self.collectionView.visibleCells.first, let indexPath = self.collectionView.indexPath(for: cell) {
            self.pageControl.currentPage = indexPath.row
        }
    }
    
}
