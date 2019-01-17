//
//  InstaPickDetailViewController.swift
//  Depo
//
//  Created by Raman Harhun on 1/14/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class InstaPickDetailViewController: UIViewController {
    
    //MARK: IBOutlet
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var analysisLeftLabel: UILabel!
    @IBOutlet private weak var hashTagsLabel: UILabel!
    @IBOutlet private weak var copyToClipboardButton: UIButton!
    @IBOutlet private weak var shareButton: BlueButtonWithWhiteText!
    
    @IBOutlet private weak var darkView: UIView!
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet var instaPickPhotoViews: [InstaPickPhotoView]!
    
    //MARK: Mock
    ///Remove after server become ready
    var analyzes: [InstapickAnalyze] = [InstapickAnalyze(requestIdentifier: "123",
                                                       rank: 7.7,
                                                       hashTags: ["#lifebox", "#xmas", "#orangeSoft",
                                                                  "#wrtht", "#instaPick", "#hipster",
                                                                  "#fun", "#summer", "#photo",
                                                                  "#oohs", "#friend", "#best"],
                                                       fileInfo: nil,
                                                       photoCount: 5,
                                                       startedDate: Date()),
                                        InstapickAnalyze(requestIdentifier: "345",
                                                         rank: 7.4,
                                                         hashTags: ["#8474", "#13534523", "#wrg",
                                                                    "#fun", "#wwhgwtrh", "#wrwt53wrth",
                                                                    "#wrth", "#wrthwrtwt", "#4535"],
                                                         fileInfo: nil,
                                                         photoCount: 5,
                                                         startedDate: Date()),
                                        InstapickAnalyze(requestIdentifier: "1233",
                                                         rank: 2.7,
                                                         hashTags: ["#gwhwrgwr", "#wtwrwrtg", "#wrg",
                                                                    "#wfgwrg", "#wrgwrg",
                                                                    "#fun", "#wwhgwtrh", "#wrwtwrth",
                                                                    "#wrth", "#wrthwt"],
                                                         fileInfo: nil,
                                                         photoCount: 5,
                                                         startedDate: Date()),
                                        InstapickAnalyze(requestIdentifier: "2342",
                                                         rank: 8.7,
                                                         hashTags: ["#wrthr", "#wtwetyjetyjrwrtg", "#wrg",
                                                                    "#wfgwrg", "#wrgwrg", "#wrwttgw",
                                                                    "#ulip'p", "#hethe", "#wrwtwrth",
                                                                    "#wrth", "#wrthwrtwt", "#wrthwt"],
                                                         fileInfo: nil,
                                                         photoCount: 5,
                                                         startedDate: Date()),
                                        InstapickAnalyze(requestIdentifier: "34535",
                                                         rank: 9.7,
                                                         hashTags: ["#wtwrwrtg", "#wrg",
                                                                    "#wfgwrg", "#wrwttgw",
                                                                    "#fun", "#wwhgwtrh", "#wrwtwrth",
                                                                    "#wrth", "#wrthwrtwt", "#wrthwt"],
                                                         fileInfo: nil,
                                                         photoCount: 5,
                                                         startedDate: Date())]
    
    var photoUrls = ["https://www.irishtimes.com/polopoly_fs/1.3103126.1496249528!/image/image.jpg_gen/derivatives/box_620_330/image.jpg",
                     "https://imgs.smoothradio.com/images/11045?crop=16_9&width=660&relax=1&signature=fQibOhAoATw9IS6IxqXXXyXyvQ4=",
                     "https://www.telegraph.co.uk/content/dam/films/2017/03/20/bean_trans_NvBQzQNjv4BqFNKJvd-mi0anfcfhLYGg39oWbqNtszRryLrO6EuiQ.png?imwidth=1400",
                     "https://cdn.dnaindia.com/sites/default/files/styles/full/public/2018/07/19/706762-rowan-atkinson.jpg",
                     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjC0cQTdNUh9Uyf3h7jgzar-aAb4PI4bRLt21gmDVCRVRPiSZd"]

    //MARK: Vars
    private var hashtags: [String] = []
    
    private var isShown = false
    private var selectedPhoto: InstapickAnalyze?
    private var leftCount: String = "0"
    private var totalCount: String = "32"

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
        
        leftCount = String(analyzesCount.left)
        totalCount = String(analyzesCount.total)
    }
    
    //tmp
    ///REMOVE AFTER
    func configure(with hashtagS: String) {

    }
    
    //MARK: - Utility Methods(private)
    private func open() {
        if isShown {
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
        prepareToAppear()
        setupPhotoViews()
        setupCollectionView()
        setupFonts()
        setupTexts()
    }
    
    private func setupPhotoViews() {
        let maxCount = analyzes.count
        for (index, photoView) in instaPickPhotoViews.enumerated() {
            if maxCount >= (index + 1) {
//                photoView.configureImageView(with: analyzes[index], delegate: self)
                let url = URL(string: photoUrls[index]) //tmp
                photoView.configureImageView(with: analyzes[index], url: url, delegate: self)
            } else {
                photoView.isHidden = true
            }
        }
    }
    
    private func setupCollectionView() {
        let layout = InstaPickCollectionViewFlowLayout()
        ///distance between cells makes by shadow space
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
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
        let text = String(format: TextConstants.instaPickLeftCountLabel, leftCount, totalCount)
        if leftCount == "0", let location = text.firstIndex(of: ":") {
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
        if analyzes.count > 0 {
            analyzes.sort(by: { left, right in
                return left.rank > right.rank
            })
            
            analyzes.first?.isPicked = true
            
            let topRatePhoto = analyzes[0]
            hashtags = topRatePhoto.hashTags
            
            selectedPhoto = topRatePhoto
        } else {
            let error = CustomErrors.text("Error. There are no any photos to show.")
            showErrorWith(message: error.localizedDescription)
        }
    }
    
    private func setNewSelectedPhoto(with id: String) {
        guard let newSelectedPhotoIndex = analyzes.firstIndex(where: { $0.requestIdentifier == id }) else {
            let error = CustomErrors.text("An error occurred while changing selected photo. Not found photo with id: \(id)")
            showErrorWith(message: error.localizedDescription)
            return
        }
        
        analyzes.swapAt(0, newSelectedPhotoIndex)
        photoUrls.swapAt(0, newSelectedPhotoIndex)
        
        setupPhotoViews()
        
        let newSelectedPhoto = analyzes.first
        hashtags = newSelectedPhoto?.hashTags ?? []
        collectionView.reloadData()
        
        selectedPhoto = newSelectedPhoto
    }
    
    private func openImage() {
        let router = RouterVC()
        guard let selectedPhoto = selectedPhoto else { return } //tmp
//        guard let selectedPhoto = selectedPhoto, selectedPhoto.getLargeImageURL() != nil else {
//            let error = CustomErrors.text("Error. There is no url for large photo.")
//            showErrorWith(message: error)
//            return
//        }
        let wrappedData = Item(instaPickAnalyzeModel: selectedPhoto)
        let controller = router.filesDetailViewControllerForInstaPick(fileObject: wrappedData, items: [wrappedData])
        let nController = NavigationController(rootViewController: controller)
        self.present(nController, animated: true, completion: nil) ///routerVC not work
    }
    
    private func showErrorWith(message: String) {
        UIApplication.showErrorAlert(message: message)
    }
    
    //MARK: - Actions
    @IBAction private func onCopyToClipboardTap(_ sender: Any) {
        ///Is it need? In task you should by press include it to share but I think its unclear for user
        let clipboardString = hashtags.joined()
        UIPasteboard.general.string = clipboardString
    }
    
    @IBAction private func onShareTap(_ sender: Any) {
//        guard let url: URL = selectedPhoto?.getLargeImageURL() else {
//            let error = CustomErrors.text("Error. There is no url for large photo.")
//            showErrorWith(message: error)
//            return
//        }
        let url = photoUrls[0] //tmp
        let clipboardString = hashtags.joined()
        let activityVC = UIActivityViewController(activityItems: [clipboardString, url], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil) ///routerVC not work
    }
    
    @IBAction private func onCloseTap(_ sender: Any) {
        close()
    }
}

//MARK: - UICollectionViewDataSource
extension InstaPickDetailViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hashtags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(cell: InstaPickHashtagCell.self, for: indexPath)
        cell.configure(with: hashtags[indexPath.row], delegate: self)
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension InstaPickDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = hashtags[indexPath.row].width(for: 23, font: UIFont.TurkcellSaturaMedFont(size: 10)) + NumericConstants.instaPickHashtagCellWidthConstant
        return CGSize(width: width, height: NumericConstants.instaPickHashtagCellHeight)
    }
}

//MARK: - InstaPickHashtagCellDelegate
extension InstaPickDetailViewController: InstaPickHashtagCellDelegate {
    func dismissCell(with hashtag: String) {
        guard let index = hashtags.index(of: hashtag) else { return }
        hashtags.remove(at: index)
        let indexPath = IndexPath(item: index, section: 0)
        collectionView?.performBatchUpdates({ [weak self] in
            self?.collectionView?.deleteItems(at: [indexPath])
            }, completion: nil)
    }
}

extension InstaPickDetailViewController: InstaPickPhotoViewDelegate {
    func didTapOnImage(_ id: String) {
        if selectedPhoto?.requestIdentifier == id {
            openImage()
        } else {
            setNewSelectedPhoto(with: id)
        }
    }
}
