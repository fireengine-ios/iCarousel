//
//  OverlayStickerViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit
import Photos
import YYImage

///Static parameters for UI elements set up in OverlayStickerViewControllerDesigner
final class OverlayStickerViewController: ViewController {

    @IBOutlet private weak var overlayingStickerImageView: OverlayStickerImageView!
    @IBOutlet private weak var gifButton: UIButton!
    @IBOutlet private weak var stickerButton: UIButton!
    @IBOutlet private weak var stickersCollectionView: UICollectionView!
    @IBOutlet private weak var stickersView: UIView!
    @IBOutlet private var overlayStickerViewControllerDataSource: OverlayStickerViewControllerDataSource!
    
    private let uploadService = UploadService()
    private lazy var coreDataStack: CoreDataStack = factory.resolve()
    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private let stickerService = SmashServiceImpl()
    private lazy var overlayAnimationService = OverlayAnimationService()
    private lazy var router = RouterVC()
    
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
    
    var selectedImage: UIImage? {
        didSet {
            setupEnvironment()
        }
    }
    
    var imageName: String?
//    var smashCoordinator: SmashServiceProtocol?
    var smashActionService: SmashActionServiceProtocol?

    private lazy var defaultName = UUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = .black
        statusBarColor = .black
        showSpinner()

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

        smashActionService?.startOperation { [weak self] isConfirmed in
            guard let self = self else {
                return
            }
            
            let eventLable = self.overlayingStickerImageView.getAttachmentInfoForAnalytics()
            self.analyticsService.logScreen(screen: .smashConfirmPopUp)
            self.analyticsService.trackCustomGAEvent(eventCategory: .functions,
                                                     eventActions: .smashSave,
                                                     eventLabel: eventLable)
            self.analyticsService.trackCustomGAEvent(eventCategory: .popUp,
                                                     eventActions: .smashConfirmPopUp,
                                                     eventLabel: isConfirmed ? .ok : .cancel)
            
            let gifsToStickersIds = self.overlayingStickerImageView.getAttachmentGifStickersIDs()
            let event = NetmeraEvents.Actions.SmashSave(action: isConfirmed ? .save : .cancel,
                                                        stickerId: gifsToStickersIds.gifsIDs,
                                                        gifId: gifsToStickersIds.stickersIDs)
            AnalyticsService.sendNetmeraEvent(event: event)
            
            if isConfirmed {
                self.showSpinnerIncludeNavigationBar()
                
                guard let (originalImage, attachments) = self.overlayingStickerImageView.getCondition() else {
                    assertionFailure()
                    return
                }
                
                self.overlayStickers(resultName: self.imageName ?? self.defaultName,
                                     originalImage: originalImage,
                                     attachments: attachments) { [weak self] result in
                                        self?.saveResult(result: result)
                }
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

    private func showCompletionPopUp() {
        analyticsService.logScreen(screen: .saveSmashSuccessfullyPopUp)
        smashActionService?.smashSuccessed()
    }
    
    private func showPhotoVideoPreview(item: WrapData) {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.SmashPreview())
        let detailModule = router.filesDetailModule(fileObject: item,
                                                    items: [item],
                                                    status: item.status,
                                                    canLoadMoreItems: false,
                                                    moduleOutput: nil)

        let nController = NavigationController(rootViewController: detailModule.controller)
        router.presentViewController(controller: nController)
        
        showCompletionPopUp()
    }

    private func saveResult(result: CreateOverlayStickersResult) {
        
        checkLibraryAccessStatus { [weak self] libraryIsAvailable in
            
            if libraryIsAvailable == true {
                
                let commonCompletionHandler: (WrapData?, Error?)->() = { [weak self] remoteItem, error in
                    DispatchQueue.main.async {
                        self?.hideSpinnerIncludeNavigationBar()
                        self?.close { [weak self] in
                            if let itemToShow = remoteItem {
                                self?.showPhotoVideoPreview(item: itemToShow)
                                self?.analyticsService.logScreen(screen: .smashPreview)
                            }  else if error?.isOutOfSpaceError == true {
                                self?.onOutOfSpaceError()
                            }
                        }
                    }
                }
                
                switch result {
                case .success(let result):
                    self?.saveLocalyItem(url: result.url, type: result.type, completion: { [weak self] saveResult in
                        switch saveResult {
                        case .success(let localItem):
                            self?.uploadItem(item: localItem, completion: { uploadResult in
                                switch uploadResult {
                                case .success(let remote):
                                    remote?.patchToPreview = localItem.patchToPreview
                                    commonCompletionHandler(remote, nil)
                                    
                                case .failed(let error):
                                    commonCompletionHandler(nil, error)
                                }
                            })
                            
                        case .failed(let error):
                            commonCompletionHandler(nil, error)
                        }
                    })
                    
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
    
    @objc private func closeIconTapped() {
        let gifsToStickersIds = self.overlayingStickerImageView.getAttachmentGifStickersIDs()
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.SmashSave(action: .cancel, stickerId: gifsToStickersIds.gifsIDs, gifId: gifsToStickersIds.stickersIDs))   
        close()
    }
    
    @objc private func close(completion: VoidHandler? = nil) {
        DispatchQueue.toMain {
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    private func onOutOfSpaceError() {
        RouterVC().showFullQuotaPopUp()
    }
    
    private func setupEnvironment() {
        guard let selectedImage = selectedImage else {
            assertionFailure()
            return
        }
        
        loadView()
        view.backgroundColor = .black
        
        selectStickerType(type: .gif)
        
        overlayingStickerImageView.stickersDelegate = self
        overlayStickerViewControllerDataSource.delegate = self
        overlayStickerViewControllerDataSource.loadNext()
        overlayingStickerImageView.image = selectedImage
    }
    
    private func setupNavigationBar() {
        title = TextConstants.smashScreenTitle
        navigationBarWithGradientStyle()
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = applyButton
        navigationController?.navigationBar.isHidden = false
    }
    
    private func makeTopAndBottomBarsIsHidden(hide: Bool) {
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.navigationController?.navigationBar.isHidden = hide
            self.stickersView.isHidden = hide
        }
    }
    
    @objc private func actionFullscreenTapGesture() {
        isFullScreen = !isFullScreen
        makeTopAndBottomBarsIsHidden(hide: isFullScreen)
    }

    private func checkLibraryAccessStatus(completion: @escaping BoolHandler) {
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
    
    func didSelectItem(item: SmashStickerResponse, attachmentType: AttachedEntityType) {
        
        showSpinner()
        overlayingStickerImageView.addAttachment(item: item, attachmentType: attachmentType, completion: { [weak self] in
            self?.hideSpinner()
        })
    }
}


//MARK: - Saving

extension OverlayStickerViewController {
    private func uploadItem(item: WrapData, completion: @escaping ResponseHandler<WrapData?>) {
        var uploadOperation: UploadOperation?
        uploadService.uploadFileList(items: [item],
                                     uploadType: .syncToUse,
                                     uploadStategy: .WithoutConflictControl,
                                     uploadTo: .MOBILE_UPLOAD,
                                     success: {
                                        completion(.success(uploadOperation?.outputItem)) },
                                     fail: { errorResponce in
                                        completion(.failed(errorResponce)) },
                                     returnedUploadOperation: { operations in
                                        uploadOperation = operations?.first
        })
    }

    private func saveLocalyItem(url: URL, type: CreateOverlayResultType, completion: @escaping ResponseHandler<WrapData>) {
        LocalMediaStorage.default.saveToGallery(fileUrl: url, type: type.toPHMediaType) { [weak self] result in
            switch result {
            case .success(let placeholder):
                guard
                    let assetIdentifier = placeholder?.localIdentifier,
                    let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
                else {
                    assertionFailure()
                    completion(.failed(ErrorResponse.string(TextConstants.errorUnknown)))
                    return
                }
                
                self?.saveToDB(asset: asset, completion: completion)
                
            case .failed(_):
                completion(.failed(ErrorResponse.string(TextConstants.errorUnknown)))
            }
        }
    }
    
    private func saveToDB(asset: PHAsset, completion: @escaping ResponseHandler<WrapData>) {
        let mediaItemService = MediaItemOperationsService.shared
        LocalMediaStorage.default.assetsCache.append(list: [asset])
        mediaItemService.append(localMediaItems: [asset]) { [weak self] in
            guard let self = self else {
                return
            }
            
            let context = self.coreDataStack.newChildBackgroundContext
            mediaItemService.mediaItems(by: asset.localIdentifier, context: context, mediaItemsCallBack: { items in
                guard let savedLocalItem = items.first else {
                    assertionFailure()
                    completion(.failed(ErrorResponse.string(TextConstants.errorUnknown)))
                    return
                }
                
                let wrapData = WrapData(mediaItem: savedLocalItem, asset: asset)
                completion(.success(wrapData))
            })
        }
    }
}

extension OverlayStickerViewController {
    
    private func overlayStickers(resultName: String, originalImage: UIImage, attachments: [UIImageView], completion: @escaping (CreateOverlayStickersResult) -> ()) {
        
        if attachments.contains(where: { $0 is YYAnimatedImageView}) {
        overlayAnimationService.combine(attachments: attachments, resultName: resultName, originalImage: originalImage, completion: completion)
            
        } else {
            
            guard let image = UIImage.imageWithView(view: overlayingStickerImageView) else {
                completion(.failure(.unknown))
                return
            }
            saveImage(image: image, fileName: resultName, completion: completion)
        }
    }
    
    private func saveImage(image: UIImage, fileName: String, completion: (CreateOverlayStickersResult) -> ()) {
        guard let data = image.jpeg(.highest) ?? UIImagePNGRepresentation(image) else {
            completion(.failure(.unknown))
            return
        }
        
        let format = ImageFormat.get(from: data) == .jpg ? ".jpg" : ".png"
        
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            completion(.failure(.unknown))
            return
        }
        
        do {
            guard let path = directory.appendingPathComponent(fileName + format) else {
                assertionFailure()
                completion(.failure(.unknown))
                return
            }
            try data.write(to: path)
            completion(.success(CreateOverlayStickersSuccessResult(url: path, type: .image)))
        } catch {
            completion(.failure(.unknown))
        }
    }
}
