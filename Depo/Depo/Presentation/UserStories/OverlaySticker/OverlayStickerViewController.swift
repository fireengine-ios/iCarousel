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

    @IBOutlet private weak var overlayingStickerImageView: OverlayStickerImageView!
    @IBOutlet private weak var gifButton: UIButton!
    @IBOutlet private weak var stickerButton: UIButton!
    @IBOutlet private weak var stickersCollectionView: UICollectionView!
    @IBOutlet private weak var stickersView: UIView!
    @IBOutlet private var overlayStickerViewControllerDataSource: OverlayStickerViewControllerDataSource!
    
    private let uploadService = UploadService()
    
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
    
    private var isFullScreen = false
    
    var selectedImage: UIImage?
    var imageName: String?
    private lazy var defaultName = UUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectStickerType(type: .gif)
        setupImage()
        statusBarColor = .black
        overlayingStickerImageView.stickersDelegate = self
        overlayStickerViewControllerDataSource.delegate = self
        overlayStickerViewControllerDataSource.setStateForSelectedType(type: .gif)

        addTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    @IBAction private func gifButtonTapped(_ sender: Any) {
        selectStickerType(type: .gif)
    }
    
    @IBAction private func imageButton(_ sender: Any) {
        selectStickerType(type: .image)
    }
    
    @IBAction private func undoButtonTapped(_ sender: Any) {
        overlayingStickerImageView.removeLast()
    }
    
    @objc private func applyIconTapped() {
        
        guard LocalMediaStorage.default.photoLibraryIsAvailible() else {
            showAccessAlert()
            return
        }

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
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionFullscreenTapGesture))
        overlayingStickerImageView.addGestureRecognizer(tapGesture)
    }
    
    private func selectStickerType(type: AttachedEntityType) {
        
        overlayStickerViewControllerDataSource.setStateForSelectedType(type: type)
        
        switch type {
        case .gif:
            gifButton.tintColor = UIColor.yellow
            gifButton.setTitleColor(UIColor.yellow, for: .normal)
            stickerButton.tintColor = UIColor.gray
            stickerButton.setTitleColor(UIColor.gray, for: .normal)
        case .image:
            stickerButton.tintColor = UIColor.yellow
            stickerButton.setTitleColor(UIColor.yellow, for: .normal)
            gifButton.tintColor = UIColor.gray
            gifButton.setTitleColor(UIColor.gray, for: .normal)
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
                            self?.hideSpinnerIncludeNavigationBar()
                            self?.closeIconTapped()
                        })
        
                    case .video:
                        self?.saveVideoToLibrary(url: result.url) { isSavedInLibrary in
                            print("Saved in library")
                        }
                        self?.uploadVideo(contentURL: result.url, completion: { isUploaded in
                            print("uploaded")
                            self?.hideSpinnerIncludeNavigationBar()
                            self?.closeIconTapped()
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
        navigationController?.navigationController?.navigationBar.isTranslucent = false
        self.extendedLayoutIncludesOpaqueBars = true
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
    
    private func makeTopAndBottomBarsIsHidden(hide: Bool) {
        navigationController?.setNavigationBarHidden(hide, animated: false)
        stickersView.isHidden = hide
    }
    
    @objc private func actionFullscreenTapGesture() {
        isFullScreen = !isFullScreen
        makeTopAndBottomBarsIsHidden(hide: isFullScreen)
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
}

extension OverlayStickerViewController: OverlayStickerImageViewdelegate {
    func makeTopAndBottomBarsIsHidden(isHidden: Bool) {
        guard !isFullScreen else {
            return
        }
        makeTopAndBottomBarsIsHidden(hide: isHidden)
    }
}

extension OverlayStickerViewController: OverlayStickerViewControllerDataSourceDelegate {
    
    func didSelectItemWithUrl(url: URL, attachmentType: AttachedEntityType) {
        
        showSpinner()
        overlayingStickerImageView.addAttachment(url: url, attachmentType: attachmentType, completion: { [weak self] in
            self?.hideSpinner()
        })
    }
}
