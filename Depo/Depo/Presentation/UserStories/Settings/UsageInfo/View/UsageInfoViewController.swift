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
            cardView.backgroundColor = AppColor.secondaryBackground.color
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
            cardTitleLabel.font = .appFont(.medium, size: 18)
            cardTitleLabel.textColor = AppColor.label.color
        }
    }
    
    @IBOutlet private weak var cardDividerView: UIView! {
        didSet {
            cardDividerView.backgroundColor = AppColor.itemSeperator.color
        }
    }

    @IBOutlet private weak var photoUsageInfoView: MediaUsageInfoView!
    @IBOutlet private weak var videoUsageInfoView: MediaUsageInfoView!
    @IBOutlet private weak var musicUsageInfoView: MediaUsageInfoView!
    @IBOutlet private weak var docsUsageInfoView: MediaUsageInfoView!
    
    @IBOutlet private weak var circleProgressView: CircleProgressView! {
        didSet {
            circleProgressView.backWidth = NumericConstants.usageInfoProgressWidth / 5
            circleProgressView.progressWidth = NumericConstants.usageInfoProgressWidth
            circleProgressView.progressRatio = 0.0
            circleProgressView.progressColor = AppColor.snackbarBackground.color
            circleProgressView.backColor = AppColor.snackbarBackground.color
                .withAlphaComponent(NumericConstants.progressViewBackgroundColorAlpha)
        }
    }
    
    @IBOutlet private weak var usagePercentageLabel: UILabel! {
        didSet {
            usagePercentageLabel.text = String(format: TextConstants.usagePercentageTwoLines, 0)
            usagePercentageLabel.textAlignment = .center
            usagePercentageLabel.numberOfLines = 0
            usagePercentageLabel.textColor = AppColor.snackbarBackground.color
            usagePercentageLabel.font = .appFont(.medium, size: 16)
            usagePercentageLabel.adjustsFontSizeToFitWidth()
        }
    }
    
    @IBOutlet private weak var wholeStorageDetailLabel: UILabel! {
        didSet {
            let zero = Int64(0).bytesString
            wholeStorageDetailLabel.text = String(format: TextConstants.usedAndLeftSpace, zero, zero)
            wholeStorageDetailLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet private weak var upgradeButton: DarkBlueButton! {
        didSet {
            upgradeButton.setTitle(TextConstants.fullQuotaSmallPopUpSecondButtonTitle, for: .normal)
      
        }
    }
    
    @IBOutlet weak var myDataUsageLabel: UILabel! {
        didSet {
            myDataUsageLabel.text = TextConstants.myUsageStorage
            myDataUsageLabel.textColor = AppColor.label.color
            myDataUsageLabel.font = .appFont(.medium, size: 14)
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
    
    @IBOutlet weak var usageViewHight: NSLayoutConstraint!
    
    @IBOutlet private weak var pageControl: UIPageControl! {
        didSet {
            pageControl.currentPage = 0
            pageControl.hidesForSinglePage = true
            pageControl.isUserInteractionEnabled = false
            pageControl.currentPageIndicatorTintColor = AppColor.snackbarBackground.color
            pageControl.pageIndicatorTintColor = AppColor.snackbarBackground.color.withAlphaComponent(0.25)
        }
    }
    
    @IBOutlet weak var toggleButton: UIButton! {
        willSet {
            // normal
            newValue.setTitle(TextConstants.launchCampaignCardDetail, for: .normal)
            newValue.setTitleColor(AppColor.label.color, for: .normal)
            newValue.setImage(Image.iconArrowUpSmall.image, for: .normal)
            
            // selected
            newValue.setTitle(TextConstants.launchCampaignCardDetail, for: .selected)
            newValue.setTitleColor(AppColor.label.color, for: .selected)
            newValue.setImage(Image.iconArrowDownSmall.image, for: .selected)
            
            newValue.forceImageToRightSide()
            newValue.titleLabel?.font = .appFont(.medium, size: 14)
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
    
    private static let totalSpacesForCell: CGFloat = 35 /// total vertical spaces between labels including bar
    private static let offsetForCellLabels: CGFloat = 8 /// left and right offset

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

    @IBAction func toggleButtonAction(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        guard let viewToAnimate = cardView.subviews.first(where: { $0.tag == 123 }) else {
            return
        }
                
        if sender.isSelected {
            usageViewHight.constant = 0
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                viewToAnimate.isHidden = true
                self.view.layoutIfNeeded()
            })
            
        } else {
            usageViewHight.constant = 90
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                viewToAnimate.isHidden = false
                self.view.layoutIfNeeded()
            })
        }
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
        setTitle(withString: TextConstants.usage)
    }
    
    ///This method need to calculate height for collectionView.
    ///It's need to make dynamic cells and we use highest cell as hneight for collectionView
    private func calculateHeightForCollectionView(with models: [InternetDataUsage]) {
        var biggerHeight: CGFloat = 0
        
        let commonWidth = collectionView.frame.width - UsageInfoViewController.offsetForCellLabels
        
        models.forEach { model in
            var cellHeight = UsageInfoViewController.totalSpacesForCell
            
            let usedVolume: CGFloat
            if let remaining = model.remaining, let total = model.total {
                usedVolume = CGFloat((1 - (remaining / total)) * 100)
            } else {
                usedVolume = 0
            }
            
            let textHeight: CGFloat = 25
            let usagePercentage = String(format: TextConstants.usagePercentage, usedVolume.rounded(.toNearestOrAwayFromZero))
            let widthForName = commonWidth - usagePercentage.width(for: textHeight, font: .TurkcellSaturaDemFont(size: 16))
            
            cellHeight += model.offerName?.height(for: widthForName, font: .TurkcellSaturaMedFont(size: 18)) ?? 0
            
            let packageSpaceDetails = String(format: TextConstants.packageSpaceDetails, model.usedString, model.totalString)
            cellHeight += packageSpaceDetails.height(for: commonWidth, font: .TurkcellSaturaRegFont(size: 18))

            if let dateString = model.expiryDate?.getDateInFormat(format: "dd MMM YYYY") {
                cellHeight += String(format: TextConstants.renewDate, dateString)
                    .height(for: commonWidth, font: .TurkcellSaturaRegFont(size: 14))
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
        
        wholeStorageDetailLabelAttribute(usedBytes: usedBytes.bytesString, quotaBytes: quotaBytes.bytesString)
        
        let usagePercentage = CGFloat(usedBytes) / CGFloat(quotaBytes)
        circleProgressView.set(progress: usagePercentage,
                               withAnimation: false)
        
        let percentage = (usagePercentage  * 100).rounded(.toNearestOrAwayFromZero)
        usagePercentageLabelAttribute(with: percentage)

        self.internetDataUsages = usage.internetDataUsage
        calculateHeightForCollectionView(with: self.internetDataUsages)
        
        ///needs to redraw progress view
        circleProgressView.layoutIfNeeded()
        
        collectionView.reloadData()
    }
    
    private func wholeStorageDetailLabelAttribute(usedBytes: String, quotaBytes: String) {
        let bytesStr = "\(usedBytes)/ \(quotaBytes)"
        
        let attributedString = NSMutableAttributedString(string: bytesStr)
        
        // Set font and size for usedBytes
        let usedBytesRange = (bytesStr as NSString).range(of: usedBytes)
        attributedString.addAttribute(.font, value: UIFont.appFont(.regular, size: 14), range: usedBytesRange)
        attributedString.addAttribute(.foregroundColor, value: AppColor.label.color, range: usedBytesRange)
        
        
        // Set font and size for quotaBytes
        let quotaBytesRange = (bytesStr as NSString).range(of: quotaBytes)
        attributedString.addAttribute(.font, value: UIFont.appFont(.medium, size: 18), range: quotaBytesRange)
        attributedString.addAttribute(.foregroundColor, value: AppColor.label.color, range: quotaBytesRange)
        
        wholeStorageDetailLabel.attributedText = attributedString
    }
    
    private func usagePercentageLabelAttribute(with percentage: CGFloat) {
        let string = String(format: TextConstants.usagePercentageTwoLines, percentage)
        
        // string is like "%20\nused"
        let separated = string.components(separatedBy: "\n")
        guard let used = separated.last else { return }
        var number = separated[0]
        guard let first = number.popLast() else { return }
        
        let attributedString = NSMutableAttributedString(string: string)

        // Set font and size for "%" character
        let percentRange = (string as NSString).range(of: first.description)
        attributedString.addAttribute(.font, value: UIFont.appFont(.light, size: 20), range: percentRange)
        attributedString.addAttribute(.foregroundColor, value: AppColor.progressFront.color, range: percentRange)

        // Set font and size for float part
        let floatRange = (string as NSString).range(of: number)
        attributedString.addAttribute(.font, value: UIFont.appFont(.bold, size: 24), range: floatRange)
        attributedString.addAttribute(.foregroundColor, value: AppColor.progressFront.color, range: floatRange)

        // Set font and size for "used" string
        let usedRange = (string as NSString).range(of: used)
        attributedString.addAttribute(.font, value: UIFont.appFont(.regular, size: 20), range: usedRange)
        attributedString.addAttribute(.foregroundColor, value: AppColor.progressFront.color, range: usedRange)
        
        usagePercentageLabel.attributedText = attributedString
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
