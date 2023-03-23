//
//  InstaPickDetailViewController.swift
//  Depo
//
//  Created by Raman Harhun on 1/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickDetailViewController: BaseViewController {
    //MARK: IBOutlet
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var analysisLeftLabel: UILabel!
    @IBOutlet private weak var hashTagsLabel: UILabel!
    @IBOutlet private weak var copyToClipboardButton: UIButton!
    @IBOutlet private weak var shareButton: DarkBlueButton!
    
    
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var hashtagShadowView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 16
            newValue.layer.shadowOffset = .zero
            newValue.layer.shadowOpacity = 0.2
            newValue.layer.shadowRadius = 16
            newValue.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
            newValue.clipsToBounds = true
        }
    }
    @IBOutlet private weak var containerView: UIView! {
        willSet {
            newValue.layer.cornerRadius = 16
            newValue.clipsToBounds = true
            newValue.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    @IBOutlet weak var smallPhotosCollectionView: UICollectionView!
        
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.layer.cornerRadius = 16
            newValue.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var instaPickPhotoViews: InstaPickBigPhotoView!
    
    //MARK: Vars
    private var dataSource = InstaPickHashtagCollectionViewDataSource()
    private var smallPhotoDataSource = InstaPickSmallPhotoCollectionViewDataSource()
    private var isShown = false
    private var selectedPhoto: InstapickAnalyze?

    private var analyzes: [InstapickAnalyze] = []
    private var analyzesCount: InstapickAnalyzesCount?
    
    private lazy var activityManager = ActivityIndicatorManager()
    private lazy var analyticsService: AnalyticsService = factory.resolve()

    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        trackScreen()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        open()
    }

    //MARK: - Utility Methods(public)
    func configure(with models: [InstapickAnalyze], analyzesCount: InstapickAnalyzesCount, isShowTabBar: Bool) {
        analyzes = models
        self.analyzesCount = analyzesCount
        needToShowTabBar = isShowTabBar
    }
    
    //MARK: - Utility Methods(private)
    
    private func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.PhotoPickAnalysisDetailScreen())
        let analyticsService: AnalyticsService = factory.resolve()
        analyticsService.logScreen(screen: .photoPickAnalysisDetail)
        analyticsService.trackDimentionsEveryClickGA(screen: .photoPickAnalysisDetail)
    }
    
    private func open() {
        if isShown {
            return
        }
        isShown = true
        view.alpha = 0
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
        }
    }
    
    private func close() {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func setup() {
        activityManager.delegate = self

        prepareToAppear()
        setupPhotoViews()
        setupCollectionView()
        setupFonts()
        setupTexts()
    }
    
    private func setupPhotoViews() {
        guard !analyzes.isEmpty else {
            let error = CustomErrors.serverError("There are no photos to show.")
            showErrorWith(message: error.localizedDescription)
            return
        }
            
        instaPickPhotoViews.configureImageView(with: analyzes[0])
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = dataSource
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.register(nibCell: InstaPickHashtagCell.self)
        
        smallPhotoDataSource.delegate = self
        smallPhotosCollectionView.showsHorizontalScrollIndicator = false
        smallPhotosCollectionView.collectionViewLayout = smallPhotoDataSource
        smallPhotosCollectionView.delegate = smallPhotoDataSource
        smallPhotosCollectionView.dataSource = smallPhotoDataSource
        smallPhotosCollectionView.register(nibCell: InstaPickSmallPhotoCell.self)
    }
    
    private func setupFonts() {
        let isIPad = Device.isIpad
        
        topLabel.font = .appFont(.medium, size: isIPad ? 30 : 20)
        topLabel.textColor = AppColor.label.color
        
        analysisLeftLabel.font = .appFont(.medium, size: isIPad ? 26 : 16)
        analysisLeftLabel.textColor = AppColor.label.color
        
        hashTagsLabel.font = .appFont(.medium, size: isIPad ? 26 : 16)
        hashTagsLabel.textColor = AppColor.marineTwoAndWhite.color
        
        copyToClipboardButton.titleLabel?.font = .appFont(.medium, size: isIPad ? 26 : 16)
        copyToClipboardButton.setTitleColor(AppColor.tint.color, for: .normal)
    }

    private func setupTexts() {
        topLabel.text = TextConstants.instaPickReadyToShareLabel
        
        setupAnalysisLeftLabel()
        
        hashTagsLabel.text = TextConstants.instaPickMoreHashtagsLabel
        
        copyToClipboardButton.setTitle(TextConstants.instaPickCopyHashtagsButton, for: .normal)
        
        shareButton.setTitle(TextConstants.instaPickShareButton, for: .normal)
    }
    
    private func configureShareButton(isEnabled: Bool) {
        shareButton.isEnabled = isEnabled
        
        let color = ColorConstants.darkBlueColor.lighter(by: isEnabled ? 0 : 40).cgColor
        
        shareButton.layer.borderColor = color
        shareButton.layer.borderWidth = isEnabled ? 0 : 2
    }
    
    private func setupAnalysisLeftLabel() {
        //TODO: find the way to seek needed substring(we could create one more PO Editing tag like "%@ of %@" to compare
        //TODO: and seek be this string). What do you think?
        guard let analyzesCount = analyzesCount else {
            let error = CustomErrors.serverError("An error occurred while getting analyzes count.")
            showErrorWith(message: error.localizedDescription)
            return
        }
        
        let text = analyzesCount.isFree ? TextConstants.instaPickUnlimitedLeftCountLabel :
            String(format: TextConstants.instaPickLeftCountLabel, analyzesCount.left, analyzesCount.total)
        
        ///if left count is 0 we seek ":"(not 0 because of RTL language) and draw in red
        if analyzesCount.left == 0, let location = text.firstIndex(of: ":"), !analyzesCount.isFree {
            let attributedString = NSMutableAttributedString(string: text, attributes: [
                .font : UIFont.appFont(.medium, size: Device.isIpad ? 26 : 16),
                .foregroundColor : ColorConstants.textGrayColor,
                .kern : 0.29
                ])
            
            ///will it has effect for RTL languages?
            let intLocation = text.distance(from: text.startIndex, to: location) + 1 /// + 1 to not include ":"
            let length = text.count - intLocation
            let nsRange = NSRange(location: intLocation, length: length)
            
            attributedString.addAttribute(.foregroundColor, value: ColorConstants.redGradientStart, range: nsRange)
            analysisLeftLabel.attributedText = attributedString
        } else {
            analysisLeftLabel.text = text
        }
    }
    
    private func prepareToAppear() {
        if analyzes.isEmpty {
            let error = CustomErrors.serverError("There are no photos to show.")
            showErrorWith(message: error.localizedDescription)
        } else {
            analyzes.sort(by: { left, right in
                return left.score > right.score
            })
            
            let topRatePhoto = analyzes.first

            configureShareButton(isEnabled: topRatePhoto?.fileInfo?.uuid != nil)

            topRatePhoto?.isPicked = true
            
            dataSource.hashtags = topRatePhoto?.hashTags ?? []
            
            smallPhotoDataSource.smallPhotos = Array(analyzes.dropFirst())
            
            selectedPhoto = topRatePhoto
            
            leftButton.isEnabled = false
            leftButton.isHidden = analyzes.count < 6
            rightButton.isHidden = leftButton.isHidden
        }
    }
    
    private func setNewSelectedPhoto(with model: InstapickAnalyze) {
        guard let newSelectedPhotoIndex = analyzes.firstIndex(of: model) else {
            let error = CustomErrors.serverError("An error occured while changing selected photo. Photo in nil.")
            showErrorWith(message: error.localizedDescription)
            return
        }
        
        analyzes.swapAt(0, newSelectedPhotoIndex)
        
        setupPhotoViews()
        
        dataSource.hashtags = model.hashTags
        smallPhotoDataSource.smallPhotos = Array(analyzes.dropFirst())
        
        smallPhotosCollectionView.reloadData()
        collectionView.reloadData()
        
        configureShareButton(isEnabled: model.fileInfo?.uuid != nil)
        
        selectedPhoto = model
    }
    
    private func showErrorWith(message: String) {
        UIApplication.showErrorAlert(message: message)
    }
    
    //MARK: - Actions
    @IBAction func leftButtonAction(_ sender: UIButton) {
        smallPhotoDataSource.currentIndex -= 1
        
        if smallPhotoDataSource.currentIndex <= 0 {
            smallPhotoDataSource.currentIndex = 0
            leftButton.isEnabled = false
        } else {
            rightButton.isEnabled = true
            if let _ = smallPhotosCollectionView.cellForItem(at: IndexPath(item: smallPhotoDataSource.currentIndex, section: 0)) {
                let nextIndexPath = IndexPath(item: smallPhotoDataSource.currentIndex, section: 0)
                smallPhotosCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    
    @IBAction func rightButtonAction(_ sender: UIButton) {
        smallPhotoDataSource.currentIndex += 1
        
        if smallPhotoDataSource.currentIndex >= smallPhotoDataSource.smallPhotos.count {
            smallPhotoDataSource.currentIndex = smallPhotoDataSource.smallPhotos.count - 1
            rightButton.isEnabled = false
        } else {
            leftButton.isEnabled = true
            if let _ = smallPhotosCollectionView.cellForItem(at: IndexPath(item: smallPhotoDataSource.currentIndex, section: 0)) {
                let nextIndexPath = IndexPath(item: smallPhotoDataSource.currentIndex, section: 0)
                smallPhotosCollectionView.scrollToItem(at: nextIndexPath, at: .centeredHorizontally, animated: true)
            } else {
                smallPhotoDataSource.currentIndex = smallPhotoDataSource.smallPhotos.count - 1
            }
        }
    }
    
    @IBAction private func onCopyToClipboardTap(_ sender: Any) {
        let clipboardString = dataSource.hashtags.joined()
        UIPasteboard.general.string = clipboardString
        
        SnackbarManager.shared.show(type: .nonCritical, message: TextConstants.snackbarMessageHashTagsCopied)
    }
    
    @IBAction private func onShareTap(_ sender: Any) {
        guard let fileForDownload = FileForDownload(forInstaPickAnalyze: selectedPhoto) else {
            let error = CustomErrors.serverError("There is no needed info to share.")
            showErrorWith(message: error.localizedDescription)
            return
        }
        
        let shareButtonRect = self.shareButton.convert(self.shareButton.bounds, to: self.view)

        let rect = CGRect(x: shareButtonRect.midX, y: shareButtonRect.minY - 10, width: 10, height: 0)
        
        startActivityIndicator()
        let downloader = FilesDownloader()
        downloader.getFiles(filesForDownload: [fileForDownload], response: { [weak self] urls, path in
            self?.stopActivityIndicator()
            let activityVC = UIActivityViewController(activityItems: urls, applicationActivities: nil)
            
            activityVC.completionWithItemsHandler = { [weak self] activityType, _, _, _ in
                guard
                    let activityType = activityType,
                    let activityTypeString = (activityType as NSString?) as String?
                else {
                    return
                }
                
                self?.analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                          eventActions: .photopickShare,
                                                          eventLabel: .shareViaApp(activityTypeString.knownAppName()))
            }
            
            ///works only on iPad
            activityVC.popoverPresentationController?.sourceRect = rect
            activityVC.popoverPresentationController?.sourceView = self?.view
            
            self?.present(activityVC, animated: true, completion: nil) ///routerVC not work
        }) { [weak self] errorString in
            self?.stopActivityIndicator()
            self?.showErrorWith(message: errorString)
        }
    }
    
    @IBAction private func onCloseTap(_ sender: Any) {
        close()
    }
}

extension InstaPickDetailViewController: InstaPickPhotoViewDelegate {
    func currentIndexWithScroll(index: Int) {
        if index <= 1 {
            leftButton.isEnabled = false
            rightButton.isEnabled = true
        } else if index >= smallPhotoDataSource.smallPhotos.count {
            smallPhotoDataSource.currentIndex = smallPhotoDataSource.smallPhotos.count - 1
            leftButton.isEnabled = true
            rightButton.isEnabled = false
        } else {
            leftButton.isEnabled = true
            rightButton.isEnabled = true
        }
    }
    
    func didTapOnImage(_ model: InstapickAnalyze?) {
        guard let model = model else {
            return
        }
        
        setNewSelectedPhoto(with: model)
    }
}

extension InstaPickDetailViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}
