//
//  InstaPickDetailViewController.swift
//  Depo
//
//  Created by Raman Harhun on 1/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickDetailViewController: UIViewController {
    
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
    @IBOutlet private weak var shareButton: BlueButtonWithWhiteText!
    
    @IBOutlet private weak var darkView: UIView!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var smallPhotosContainerView: UIView!
    @IBOutlet private weak var smallPhotosStackView: UIStackView!
    @IBOutlet private weak var photosStackView: UIStackView!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet var instaPickPhotoViews: [InstaPickPhotoView]!

    //MARK: Vars
    private var dataSource = InstaPickHashtagCollectionViewDataSource()
    private var isShown = false
    private var selectedPhoto: InstapickAnalyze?
    
    private var analyzes: [InstapickAnalyze] = []
    private var analyzesCount: InstapickAnalyzesCount?

    //MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        open()
    }
    
    //MARK: - Utility Methods(public)
    func configure(with models: [InstapickAnalyze], analyzesCount: InstapickAnalyzesCount) {
        analyzes = models
        self.analyzesCount = analyzesCount
    }
    
    //MARK: - Utility Methods(private)
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
                
                view.configureImageView(with: analyze, delegate: self)
            } else {
                view.isHidden = true
            }
        }
        
        if maxIndex == 0 {
            photosStackView.removeArrangedSubview(smallPhotosContainerView)
        }
    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = dataSource
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        
        collectionView.register(nibCell: InstaPickHashtagCell.self)
    }
    
    private func setupFonts() {
        topLabel.font = UIFont.TurkcellSaturaBolFont(size: 28)
        topLabel.textColor = ColorConstants.darcBlueColor
        
        analysisLeftLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        analysisLeftLabel.textColor = ColorConstants.textGrayColor
        
        hashTagsLabel.font = UIFont.TurkcellSaturaDemFont(size: 18)
        hashTagsLabel.textColor = ColorConstants.darcBlueColor
        
        copyToClipboardButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 14)
        copyToClipboardButton.setTitleColor(UIColor.lrTealishTwo, for: .normal)
        
        shareButton.titleEdgeInsets = UIEdgeInsetsMake(11, 16, 11, 16)
    }

    private func setupTexts() {
        topLabel.text = TextConstants.instaPickReadyToShareLabel
        
        setupAnalysisLeftLabel()
        
        hashTagsLabel.text = TextConstants.instaPickMoreHashtagsLabel
        
        copyToClipboardButton.setTitle(TextConstants.instaPickCopyHashtagsButton, for: .normal)
        
        shareButton.setTitle(TextConstants.instaPickShareButton, for: .normal)
    }
    
    private func setupAnalysisLeftLabel() {
        //TODO: find the way to seek needed substring(we could create one more PO Editing tag like "%@ of %@" to compare
        //TODO: and seek be this string). What do you think?
        guard let analyzesCount = analyzesCount else {
            let error = CustomErrors.serverError("An error occurred while getting analyzes count.")
            showErrorWith(message: error.localizedDescription)
            return
        }
        let text = String(format: TextConstants.instaPickLeftCountLabel, analyzesCount.left, analyzesCount.total)
        ///if left count is 0 we seek ":"(not 0 because of RTL language) and draw in red
        if analyzesCount.left == 0, let location = text.firstIndex(of: ":") {
            let attributedString = NSMutableAttributedString(string: text, attributes: [
                .font : UIFont.TurkcellSaturaDemFont(size: 18),
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
                return left.rank > right.rank
            })
            
            let topRatePhoto = analyzes.first

            topRatePhoto?.isPicked = true
            
            dataSource.hashtags = topRatePhoto?.hashTags ?? []
            
            selectedPhoto = topRatePhoto
        }
    }
    
    private func setNewSelectedPhoto(with id: String) {
        guard let newSelectedPhotoIndex = analyzes.firstIndex(where: {
            if let analyzeId = $0.fileInfo?.uuid {
               return analyzeId == id
            }
            return false
        }) else {
            let error = CustomErrors.serverError("An error occurred while changing selected photo. Not found photo with id: \(id)")
            showErrorWith(message: error.localizedDescription)
            return
        }
        
        analyzes.swapAt(0, newSelectedPhotoIndex)
        
        setupPhotoViews()
        
        let newSelectedPhoto = analyzes.first
        dataSource.hashtags = newSelectedPhoto?.hashTags ?? []
        collectionView.reloadData()
        
        selectedPhoto = newSelectedPhoto
    }
    
    private func openImage() {
        guard let selectedPhoto = selectedPhoto, selectedPhoto.getLargeImageURL() != nil else {
            let error = CustomErrors.serverError("There is no url for large photo.")
            showErrorWith(message: error.localizedDescription)
            return
        }
        
        let vc = PVViewerController.initFromNib()
        if let view = instaPickPhotoViews.first(where: { $0.restorationIdentifier == PhotoViewType.bigView.rawValue }),
            let image = view.getImage() {
            
            vc.image = image
        }
        
        let nController = NavigationController(rootViewController: vc)
        self.present(nController, animated: true, completion: nil) ///routerVC not work
    }
    
    private func showErrorWith(message: String) {
        UIApplication.showErrorAlert(message: message)
    }
    
    //MARK: - Actions
    @IBAction private func onCopyToClipboardTap(_ sender: Any) {
        let clipboardString = dataSource.hashtags.joined()
        UIPasteboard.general.string = clipboardString
    }
    
    @IBAction private func onShareTap(_ sender: Any) {
        guard let url: URL = selectedPhoto?.getLargeImageURL() else {
            let error = CustomErrors.serverError("There is no url for large photo.")
            showErrorWith(message: error.localizedDescription)
            return
        }
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil) ///routerVC not work
    }
    
    @IBAction private func onCloseTap(_ sender: Any) {
        close()
    }
}

extension InstaPickDetailViewController: InstaPickPhotoViewDelegate {
    func didTapOnImage(_ id: String?) {
        guard let id = id else {
            let error = CustomErrors.serverError("Enable to get photo metadata.")
            showErrorWith(message: error.localizedDescription)
            return
        }
        
        if let selectedPhotoId = selectedPhoto?.fileInfo?.uuid, selectedPhotoId == id {
            openImage()
        } else {
            setNewSelectedPhoto(with: id)
        }
    }
}
