//
//  InstaPickDetailViewController.swift
//  Depo
//
//  Created by Raman Harhun on 1/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickDetailViewController: BaseViewController {
    
    private enum PhotoViewType: String {
        case bigView = "bigView"
        case smallOne = "smallOne"
        case smallTwo = "smallTwo"
        case smallThree = "smallThree"
        case smallFour = "smallFour"
        case smallFive = "smallFive"
        case smallSix = "smallSix"
        
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
            case .smallFive:
                return 5
            case .smallSix:
                return 6
            }
        }
    }
    
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
    
    @IBOutlet private weak var smallPhotosStackView: UIStackView!
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        willSet {
            newValue.layer.cornerRadius = 16
            newValue.clipsToBounds = true
        }
    }
    
    @IBOutlet var instaPickPhotoViews: [InstaPickPhotoView]!

    //MARK: Vars
    private var dataSource = InstaPickHashtagCollectionViewDataSource()
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
        
        let maxIndex = analyzes.count - 1
        
        for view in instaPickPhotoViews {
            if let id = view.restorationIdentifier, let type = PhotoViewType(rawValue: id), type.index <= maxIndex {
                let analyze = analyzes[type.index]
                
                view.configureImageView(with: analyze, delegate: self, smallPhotosCount: maxIndex)
            } else {
                view.isHidden = true
            }
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
            
            selectedPhoto = topRatePhoto
            
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

        let vc = PVViewerController.with(image: image)
        let nController = NavigationController(rootViewController: vc)
        present(nController, animated: true, completion: nil) ///routerVC not work
    }
    
    private func showErrorWith(message: String) {
        UIApplication.showErrorAlert(message: message)
    }
    
    //MARK: - Actions
    
    @IBAction func leftButtonAction(_ sender: UIButton) {
        
        rotateLeft(&analyzes, by: 1)
        setupPhotoViews()
    }
    
    
    @IBAction func rightButtonAction(_ sender: UIButton) {
        rotateRight(&analyzes, by: 1)
        setupPhotoViews()
    }
    
    // Define a function to rotate the array to the left
    func rotateLeft<T>(_ array: inout [T], by rotation: Int) {
        let amount = rotation % array.count
        let slice = array[1...amount]
        array.removeSubrange(1...amount)
        array.append(contentsOf: slice)
    }

    // Define a function to rotate the array to the right
    func rotateRight<T>(_ array: inout [T], by rotation: Int) {
        let amount = rotation % array.count
        let slice = array[(array.count - amount)..<array.count]
        array.removeSubrange((array.count - amount)..<array.count)
        array.insert(contentsOf: slice, at: 1)
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
