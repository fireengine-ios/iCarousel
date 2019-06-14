//
//  InstaPickDetailViewController.swift
//  Depo
//
//  Created by Raman Harhun on 1/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickDetailViewController: UIViewController, ControlTabBarProtocol {
    
    private enum PhotoViewType: String {
        case bigView = "bigView"
        case smallOne = "smallOne"
        case smallTwo = "smallTwo"
        case smallThree = "smallThree"
        case smallFour = "smallFour"
        
        var index: Int {
            switch self {
            case .bigView:
                return 0
            case .smallOne:
                return 1
            case .smallTwo:
                return 2
            case .smallThree:
                return 3
            case .smallFour:
                return 4
            }
        }
    }
    
    //MARK: IBOutlet
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var analysisLeftLabel: UILabel!
    @IBOutlet private weak var hashTagsLabel: UILabel!
    @IBOutlet private weak var copyToClipboardButton: UIButton!
    @IBOutlet private weak var shareButton: BlueButtonWithMediumWhiteText!
    
    @IBOutlet private weak var darkView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var smallPhotosStackView: UIStackView!
    @IBOutlet private weak var smallPhotosContainerView: UIView!
    @IBOutlet private weak var photosStackView: UIStackView!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet var instaPickPhotoViews: [InstaPickPhotoView]!

    //MARK: Vars
    private var dataSource = InstaPickHashtagCollectionViewDataSource()
    private var isShown = false
    private var selectedPhoto: InstapickAnalyze?
    private var isShowTabBar = true
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showTabBarIfNeeded()
    }
    
    //MARK: - Utility Methods(public)
    func configure(with models: [InstapickAnalyze], analyzesCount: InstapickAnalyzesCount, isShowTabBar: Bool) {
        analyzes = models
        self.analyzesCount = analyzesCount
        self.isShowTabBar = isShowTabBar
    }
    
    //MARK: - Utility Methods(private)
    
    private func trackScreen() {
        let analyticsService: AnalyticsService = factory.resolve()
        analyticsService.logScreen(screen: .photoPickAnalysisDetail)
        analyticsService.trackDimentionsEveryClickGA(screen: .photoPickAnalysisDetail)
    }
    
    private func open() {
        if isShown {
            self.statusBarColor = .clear
            return
        }
        isShown = true
        containerView.transform = NumericConstants.scaleTransform
        view.alpha = 0
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.view.alpha = 1
            self.darkView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    private func close() {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.view.alpha = 0
            self.darkView.alpha = 0
            self.containerView.transform = NumericConstants.scaleTransform
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func setup() {
        activityManager.delegate = self
        containerView.layer.cornerRadius = NumericConstants.instaPickDetailsPopUpCornerRadius
        
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
        
        let maxIndex = analyzes.count - 1
        
        for view in instaPickPhotoViews {
            if let id = view.restorationIdentifier, let type = PhotoViewType(rawValue: id), type.index <= maxIndex {
                let analyze = analyzes[type.index]
                
                view.configureImageView(with: analyze, delegate: self, smallPhotosCount: maxIndex)
            } else {
                view.isHidden = true
            }
        }
        
        if maxIndex == 0 {
            smallPhotosContainerView.isHidden = true
        }
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = dataSource
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        
        collectionView.register(nibCell: InstaPickHashtagCell.self)
    }
    
    private func setupFonts() {
        let isIPad = Device.isIpad
        
        topLabel.font = UIFont.TurkcellSaturaBolFont(size: isIPad ? 38 : 28)
        topLabel.textColor = ColorConstants.darkBlueColor
        
        analysisLeftLabel.font = UIFont.TurkcellSaturaDemFont(size: isIPad ? 24 : 18)
        analysisLeftLabel.textColor = ColorConstants.textGrayColor
        
        hashTagsLabel.font = UIFont.TurkcellSaturaDemFont(size: isIPad ? 24 : 18)
        hashTagsLabel.textColor = ColorConstants.darkBlueColor
        
        copyToClipboardButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: isIPad ? 19 : 14)
        copyToClipboardButton.setTitleColor(UIColor.lrTealishTwo, for: .normal)
        
        shareButton.setBackgroundColor(UIColor.white, for: .disabled)
        shareButton.setTitleColor(ColorConstants.darkBlueColor.lighter(by: 40.0), for: .disabled)
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
        if analyzesCount.left == 0, let location = text.index(of: ":"), !analyzesCount.isFree {
            let attributedString = NSMutableAttributedString(string: text, attributes: [
                .font : UIFont.TurkcellSaturaDemFont(size: Device.isIpad ? 24 : 18),
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
            
            selectedPhoto = topRatePhoto
        }
    }
    
    private func setNewSelectedPhoto(with model: InstapickAnalyze) {
        guard let newSelectedPhotoIndex = analyzes.index(of: model) else {
            let error = CustomErrors.serverError("An error occured while changing selected photo. Photo in nil.")
            showErrorWith(message: error.localizedDescription)
            return
        }
        
        analyzes.swapAt(0, newSelectedPhotoIndex)
        
        setupPhotoViews()
        
        dataSource.hashtags = model.hashTags
        collectionView.reloadData()
        
        configureShareButton(isEnabled: model.fileInfo?.uuid != nil)
        
        selectedPhoto = model
    }
    
    private func openImage() {
        guard
            let selectedPhoto = selectedPhoto, selectedPhoto.fileInfo?.uuid != nil,
            let view = instaPickPhotoViews.first(where: { $0.restorationIdentifier == PhotoViewType.bigView.rawValue }),
            let image = view.getImage(),
            image.size != .zero
        else {
            ///if selected photo was deleted/nil/zero size
            return
        }
        
        let vc = PVViewerController.initFromNib()
        vc.image = image
        
        let nController = NavigationController(rootViewController: vc)
        self.present(nController, animated: true, completion: nil) ///routerVC not work
    }
    
    private func showErrorWith(message: String) {
        UIApplication.showErrorAlert(message: message)
    }
    
    private func showTabBarIfNeeded() {
        isShowTabBar ? showTabBar() : hideTabBar()
    }
    
    //MARK: - Actions
    @IBAction private func onCopyToClipboardTap(_ sender: Any) {
        let clipboardString = dataSource.hashtags.joined()
        UIPasteboard.general.string = clipboardString
    }
    
    @IBAction private func onShareTap(_ sender: Any) {
        guard let fileForDownload = FileForDownload(forInstaPickAnalyze: selectedPhoto) else {
            let error = CustomErrors.serverError("There is no needed info to share.")
            showErrorWith(message: error.localizedDescription)
            return
        }
        
        let shareButtonRect = self.shareButton.convert(self.shareButton.bounds, to: self.view)

        let rect = CGRect(x: shareButtonRect.midX, y: shareButtonRect.minY - 10, width: 10, height: 50)
        
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
    func didTapOnImage(_ model: InstapickAnalyze?) {
        guard let model = model else {
            return
        }
        
        if let selectedPhoto = selectedPhoto, model == selectedPhoto {
            openImage()
        } else {
            setNewSelectedPhoto(with: model)
        }
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
