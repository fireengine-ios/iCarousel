//
//  OverlayStickerViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Photos

///Static parameters for UI elements set up in OverlayStickerViewControllerDesigner

final class OverlayStickerViewController: ViewController {
    
    private struct Attachment {
        let image: UIImage
        let url: URL
    }
    
    @IBOutlet private weak var overlayingStickerImageView: OverlayStickerImageView!
    @IBOutlet private weak var gifButton: UIButton!
    @IBOutlet private weak var stickerButton: UIButton!
    @IBOutlet private weak var stickersCollectionView: UICollectionView!
    
    private let uploadService = UploadService()
    private let stickerService: SmashService = SmashServiceImpl()
    private lazy var popUpFactory = HSCompletionPopUpsFactory()
    private lazy var popUpFlowService = HideFunctionalityService()
    
    private lazy var applyButton: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        button.setImage(UIImage(named: "applyIcon"), for: .normal)
        button.addTarget(self, action: #selector(applyIconTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    private lazy var closeButton: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 44))
        button.setImage(UIImage(named: "removeCircle"), for: .normal)
        button.addTarget(self, action: #selector(closeIconTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    var selectedImage: UIImage?
    var imageName: String?
    private lazy var defaultName = UUID().uuidString
    
    private let paginationPageSize = 20
    private var isGifPaginatingFinished = false
    private var isImagePaginatingFinished = false
    private var gifPage = 0
    private var imagePage = 0
    private var isPaginating = false
    private var gifCollectionViewOffset: CGPoint = .zero
    private var imageCollectionViewOffset: CGPoint = .zero
    
    private var imageAttachment = [SmashStickerResponse]()
    private var gifAttachment = [SmashStickerResponse]()
    
    private var selectedAttachmentType: AttachedEntityType = .gif {
        didSet {
            switch selectedAttachmentType {
            case .gif:
                self.gifButton.tintColor = UIColor.yellow
                self.gifButton.setTitleColor(UIColor.yellow, for: .normal)
                self.stickerButton.tintColor = UIColor.gray
                self.stickerButton.setTitleColor(UIColor.gray, for: .normal)

                imageCollectionViewOffset = stickersCollectionView.contentOffset
                stickersCollectionView.reloadData()

                stickersCollectionView.layoutIfNeeded()
                DispatchQueue.main.async {
                     self.stickersCollectionView.contentOffset = self.gifCollectionViewOffset
                }
            case .image:
                self.stickerButton.tintColor = UIColor.yellow
                self.stickerButton.setTitleColor(UIColor.yellow, for: .normal)
                self.gifButton.tintColor = UIColor.gray
                self.gifButton.setTitleColor(UIColor.gray, for: .normal)

                gifCollectionViewOffset = stickersCollectionView.contentOffset
                
                if imageAttachment.isEmpty {
                    loadNext()
                    
                } else {
                    stickersCollectionView.reloadData()
                    stickersCollectionView.layoutIfNeeded()
                    DispatchQueue.main.async {
                        self.stickersCollectionView.contentOffset = self.imageCollectionViewOffset
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedAttachmentType = .gif
        setupImage()
        stickersCollectionView.delegate = self
        stickersCollectionView.dataSource = self
        loadNext()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    @IBAction private func gifButtonTapped(_ sender: Any) {
        selectedAttachmentType = .gif
    }
    
    @IBAction private func stickerButton(_ sender: Any) {
        selectedAttachmentType = .image
    }
    
    @IBAction private func undoButtonTapped(_ sender: Any) {
        overlayingStickerImageView.removeLast()
    }
    
    @objc private func applyIconTapped() {
        
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            showAccessAlert()
            return
        }
        
//        showFullscreenHUD(with: nil, and: {})
        showSpinnerIncludeNavigationBar()
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else {
                return
            }

            self.overlayingStickerImageView.overlayStickers(resultName: self.imageName ?? self.defaultName) { [weak self] result in
                self?.hideSpinnerIncludeNavigationBar()
                
                let popUp = PopUpController.with(title: TextConstants.save,
                                                 message: TextConstants.smashPopUpMessage,
                                                 image: .error,
                                                 firstButtonTitle: TextConstants.cancel,
                                                 secondButtonTitle: TextConstants.ok,
                                                 firstUrl: nil,
                                                 secondUrl: nil,
                                                 firstAction: { popup in popup.close() },
                                                 secondAction: { popup in
                                                    popup.close()
                                                    self?.showSpinnerIncludeNavigationBar()
                                                    self?.saveResult(result: result)
                })
                self?.hideSpinnerIncludeNavigationBar()
                UIApplication.topController()?.present(popUp, animated: true, completion: nil)
            }
        }

    }
    
    private func showAccessAlert() {
        debugLog("CameraService showAccessAlert")
        DispatchQueue.main.async {
            let controller = PopUpController.with(title: TextConstants.cameraAccessAlertTitle,
                                                  message: TextConstants.cameraAccessAlertText,
                                                  image: .none,
                                                  firstButtonTitle: TextConstants.cameraAccessAlertNo,
                                                  secondButtonTitle: TextConstants.cameraAccessAlertGoToSettings,
                                                  secondAction: { vc in
                                                    vc.close {
                                                        UIApplication.shared.openSettings()
                                                    }
            })
            UIApplication.topController()?.present(controller, animated: false, completion: nil)
        }
    }
    
    private func showCompletionPopUp() {
        let popUp = popUpFactory.getPopUp(for: .smashCompleted, itemsCount: 1, delegate: popUpFlowService)
        popUp.dismissCompletion = { [weak self] in
            self?.closeIconTapped()
        }

        UIApplication.topController()?.present(popUp, animated: false, completion: nil)
    }
    
    private func saveResult(result: CreateOverlayStickersResult) {
        
        checkLibraryAccessStatus { [weak self] libraryIsAvailable in
            
            if libraryIsAvailable == true {
                
                switch result {
                case .success(let result):
                    switch result.type {
                    case .image:
                        //TODO: Different logic for saving result
                        self?.saveImageToLibrary(url: result.url) { isSavedInLibrary in
                            print("Saved in library")
                        }
                        self?.uploadImage(contentURL: result.url, completion: { isUploaded in
                            print("uploaded")
                            DispatchQueue.main.async {
                                self?.hideSpinnerIncludeNavigationBar()
                                self?.showCompletionPopUp()
                            }
                        })
        
                    case .video:
                        self?.saveVideoToLibrary(url: result.url) { isSavedInLibrary in
                            print("Saved in library")
                        }
                        self?.uploadVideo(contentURL: result.url, completion: { isUploaded in
                            print("uploaded")
                            DispatchQueue.main.async {
                                self?.hideSpinnerIncludeNavigationBar()
                                self?.showCompletionPopUp()
                            }
                        })
                    }
                    
                case .failure(let error):
                    self?.hideSpinnerIncludeNavigationBar()
                    UIApplication.showErrorAlert(message: error.description)
                }
            } else {
                //Show popup about getting access to photo library
                self?.hideSpinnerIncludeNavigationBar()
            }
        }
    }
    
    @objc func closeIconTapped() {
        DispatchQueue.toMain {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupImage() {
        guard let selectedImage = selectedImage else {
            assertionFailure()
            return
        }
        overlayingStickerImageView.image = selectedImage
    }
    
    private func setupNavigationBar() {
        title = TextConstants.smashScreenTitle
        navigationBarWithGradientStyle()
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = applyButton
    }
    
    private func uploadVideo(contentURL: URL, completion: @escaping (Bool) -> Void) {
        
        guard let videoData = try? Data(contentsOf: contentURL) else {
            completion(false)
            return
        }
        
        let url = URL(string: UUID().uuidString, relativeTo: RouteRequests.baseUrl)
        let item = WrapData(videoData: videoData)
        item.patchToPreview = PathForItem.remoteUrl(url)
        
        uploadService.uploadFileList(items: [item],
                                     uploadType: .syncToUse,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .MOBILE_UPLOAD,
                                     success: {
                                        completion(true) },
                                     fail: { errorResponce in
                                        completion(false) },
                                     returnedUploadOperation: {_ in })
    }
    
    private func uploadImage(contentURL: URL, completion: @escaping (Bool) -> Void) {
        
        guard let imageData = try? Data(contentsOf: contentURL) else {
            completion(false)
            return
        }
        
        let url = URL(string: UUID().uuidString, relativeTo: RouteRequests.baseUrl)
        let item = WrapData(imageData: imageData)
        item.patchToPreview = PathForItem.remoteUrl(url)
        
        uploadService.uploadFileList(items: [item],
                                     uploadType: .syncToUse,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .MOBILE_UPLOAD,
                                     success: {
                                        completion(true) },
                                     fail: { errorResponce in
                                        completion(false) },
                                     returnedUploadOperation: {_ in })
    }
    
    private func saveVideoToLibrary(url: URL, completion: @escaping (Bool) -> ()) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }) { saved, error in
            if saved {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func saveImageToLibrary(url: URL, completion: @escaping (Bool) -> ()) {
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
        }) { saved, error in
            if saved {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    private func checkLibraryAccessStatus(completion: @escaping (Bool) -> Void) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            completion(true)
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    completion(true)
                } else {
                    completion(false)
                }
            })
        }
    }
    
    private func loadNext() {
        
        let selectedType: StickerType = selectedAttachmentType == .gif ? .gif : .image
        let selectedPage = selectedAttachmentType == .gif ? gifPage : imagePage
        
        stickerService.getStickers(type: selectedType, page: selectedPage, size: paginationPageSize){ [weak self] result in
            
            guard let self = self else {
                return
            }
            
            switch result {
                
            case .success(let tuple):
                let array = tuple.0
                let type = tuple.1
                
                let isPaginatingFinished = (array.count < self.paginationPageSize)
                
                switch type {
                case .gif:
                    self.gifAttachment.append(contentsOf: array)
                    self.gifPage += 1
                    self.isGifPaginatingFinished = isPaginatingFinished
                case .image:
                    self.imageAttachment.append(contentsOf: array)
                    self.imagePage += 1
                    self.isImagePaginatingFinished = isPaginatingFinished
                }
                
                DispatchQueue.toMain {
                    self.stickersCollectionView.reloadData()
                }
                
            case .failed(_):
                break
            }
            
            self.isPaginating = false
        }
    }
}

extension OverlayStickerViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedAttachmentType == .gif ? gifAttachment.count : imageAttachment.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: StickerCollectionViewCell.self, for: indexPath)
    }
}

extension OverlayStickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? StickerCollectionViewCell else {
            return
        }
        
        let object = selectedAttachmentType == .gif ? gifAttachment[indexPath.row] : imageAttachment[indexPath.row]
        
        cell.setup(with: object)
        
        let attachmentCount = selectedAttachmentType == .gif ? gifAttachment.count : imageAttachment.count
        let isLastCell = (attachmentCount - 1 == indexPath.row)
        let isPaginatingFinished = selectedAttachmentType == .gif ? isGifPaginatingFinished : isImagePaginatingFinished
        
        if isLastCell && !isPaginating && !isPaginatingFinished {
            isPaginating = true
            loadNext()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showSpinner()
        let url = selectedAttachmentType == .gif ? gifAttachment[indexPath.row].path : imageAttachment[indexPath.row].path
        
        overlayingStickerImageView.addAttachment(url: url, attachmentType: selectedAttachmentType, completion: { [weak self] in
            self?.hideSpinner()
        })
    }
}
