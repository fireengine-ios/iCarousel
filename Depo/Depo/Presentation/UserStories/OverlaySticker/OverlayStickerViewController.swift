//
//  OverlayStickerViewController.swift
//  Depo
//
//  Created by Maxim Soldatov on 12/19/19.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

///Static parameters for UI elements set up in OverlayStickerViewControllerDesigner
final class OverlayStickerViewController: UIViewController {

    @IBOutlet private weak var overlayingStickerImageView: OverlayStickerImageView!
    @IBOutlet private weak var funNavBar: FunNavBar!
    
    @IBOutlet private weak var bottomContentView: UIStackView!
    @IBOutlet private weak var tabBar: FunTabBar!
    @IBOutlet private weak var changesBar: FunChangesBar!
    @IBOutlet private weak var stickersContainerView: UIView!
    @IBOutlet private weak var stickersCollectionView: UICollectionView!
    @IBOutlet private weak var safeAreaBottomView: UIView!

    private lazy var analyticsService: AnalyticsService = factory.resolve()
    private lazy var router = RouterVC()
    private lazy var saveManager = OverlayStickerSaveManager()
    private lazy var dataSource = OverlayStickerViewControllerDataSource(collectionView: stickersCollectionView, delegate: self)
    
    private var isFullScreen = false
    private var lastAttachments = [SmashStickerResponse]()
    
    weak var selectedImage: UIImage? {
        didSet {
            setupEnvironment()
        }
    }
    
    var imageName: String?
    var smashActionService: SmashActionServiceProtocol?

    private lazy var defaultName = UUID().uuidString
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    //MARK: - Setup
    
    private func setup() {
        view.backgroundColor = .black
        stickersContainerView.backgroundColor = ColorConstants.photoEditBackgroundColor
        safeAreaBottomView.backgroundColor = ColorConstants.photoEditBackgroundColor
        
        funNavBar.state = .initial
        funNavBar.delegate = self
        tabBar.delegate = self
        changesBar.delegate = self
        stickersContainerView.isHidden = true
    }
    
    private func setupEnvironment() {
        guard let selectedImage = selectedImage else {
            assertionFailure()
            return
        }
        
        loadViewIfNeeded()
        
        overlayingStickerImageView.stickersDelegate = self
        dataSource.setStateForSelectedType(type: .gif)
        dataSource.delegate = self
        dataSource.loadNext()
        overlayingStickerImageView.image = selectedImage
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionFullscreenTapGesture))
        overlayingStickerImageView.addGestureRecognizer(tapGesture)
    }
    
    private func save() {
        
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
                                                        stickerId: gifsToStickersIds.stickersIDs,
                                                        gifId: gifsToStickersIds.gifsIDs)
            AnalyticsService.sendNetmeraEvent(event: event)
            
            guard isConfirmed else {
                return
            }
            
            self.showSpinnerIncludeNavigationBar()
            
            guard let (originalImage, attachments) = self.overlayingStickerImageView.getCondition() else {
                assertionFailure()
                return
            }
            
            self.saveManager.saveImage(resultName: self.imageName ?? self.defaultName,
                                       originalImage: originalImage,
                                       attachments: attachments,
                                       stickerImageView: self.overlayingStickerImageView) { [weak self] result in
                
                guard let self = self else {
                    return
                }
                
                self.hideSpinnerIncludeNavigationBar()
                
                switch result {
                case .success(let remote):
                    self.smashActionService?.getUserInfo { [weak self] in
                        DispatchQueue.main.async { [weak self] in
                            self?.close { [weak self] in
                                guard let remote = remote else {
                                    return
                                }
                                self?.showPhotoVideoPreview(item: remote)
                                self?.analyticsService.logScreen(screen: .smashPreview)
                            }
                        }
                    }

                case .failed(let error):
                    if let error = error as? CreateOverlayStickerError, error == .deniedPhotoAccess {
                        self.showAccessAlert()
                    } else if error.isOutOfSpaceError {
                        self.onOutOfSpaceError()
                    } else {
                        UIApplication.showErrorAlert(message: error.description)
                    }
                }
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
    
    private func close(completion: VoidHandler? = nil) {
        DispatchQueue.toMain {
            self.dismiss(animated: false, completion: completion)
        }
    }
    
    private func onOutOfSpaceError() {
        router.showFullQuotaPopUp()
    }
    
    private func makeTopAndBottomBarsIsHidden(hide: Bool) {
        funNavBar.isHidden = hide
        bottomContentView.isHidden = hide
        safeAreaBottomView.isHidden = hide
    }
    
    @objc private func actionFullscreenTapGesture() {
        isFullScreen = !isFullScreen
        makeTopAndBottomBarsIsHidden(hide: isFullScreen)
    }
    
    private func updateNavBarState() {
        if tabBar.isHidden {
            funNavBar.state = lastAttachments.isEmpty ? .empty : .modify
        } else {
            funNavBar.state = overlayingStickerImageView.hasStickers ? .edited : .initial
        }
    }
    
    private func showClosePopup(confirmation: @escaping VoidHandler) {
        let popup = PopUpController.with(title: TextConstants.funCloseAlertTitle,
                                         message: TextConstants.funCloseAlertMessage,
                                         image: .question,
                                         firstButtonTitle: TextConstants.funCloseAlertLeftButton,
                                         secondButtonTitle: TextConstants.funCloseAlertRightButton,
                                         firstAction: { vc in
                                            vc.close()
                                         },
                                         secondAction: { vc in
                                            vc.close {
                                                confirmation()
                                            }
                                         })
        popup.presentAsDrawer()
    }
}

//MARK: - OverlayStickerImageViewDelegate

extension OverlayStickerViewController: OverlayStickerImageViewDelegate {
    func makeTopAndBottomBarsIsHidden(isHidden: Bool) {
        guard !isFullScreen else {
            return
        }
        makeTopAndBottomBarsIsHidden(hide: isHidden)
    }
    
    func didDeleteAttachments(_ attachments: [SmashStickerResponse]) {
        attachments.forEach { lastAttachments.remove($0) }
        updateNavBarState()
    }
}

//MARK: - OverlayStickerViewControllerDataSourceDelegate

extension OverlayStickerViewController: OverlayStickerViewControllerDataSourceDelegate {
    
    func didSelectItem(item: SmashStickerResponse, attachmentType: AttachedEntityType) {       
        showSpinner()
        lastAttachments.append(item)
        overlayingStickerImageView.addAttachment(item: item, attachmentType: attachmentType, completion: { [weak self] in
            self?.hideSpinner()
        })
        updateNavBarState()
    }
}

//MARK: - FunTabBarDelegate

extension OverlayStickerViewController: FunTabBarDelegate {
    func didSelectItem(_ type: AttachedEntityType) {
        changesBar.setup(with: type.title)
        dataSource.setStateForSelectedType(type: type)
        
        stickersContainerView.isHidden = false
        tabBar.isHidden = true
    }
}

//MARK: - FunNavBarDelegate

extension OverlayStickerViewController: FunNavBarDelegate {
    
    func funNavBarDidCloseTapped() {
        if !overlayingStickerImageView.hasStickers {
            confirmClose()
        }
        
        showClosePopup { [weak self] in
            self?.confirmClose()
        }
    }
    
    private func confirmClose() {
        let gifsToStickersIds = self.overlayingStickerImageView.getAttachmentGifStickersIDs()
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Actions.SmashSave(action: .cancel, stickerId: gifsToStickersIds.gifsIDs, gifId: gifsToStickersIds.stickersIDs))
        close()
    }
    
    func funNavBarDidSaveTapped() {
        save()
    }
    
    func funNavBarDidUndoTapped() {
        lastAttachments.removeLast()
        overlayingStickerImageView.removeLast()
        updateNavBarState()
    }
}

//MARK: - FunChangesBarDelegate

extension OverlayStickerViewController: FunChangesBarDelegate {
    
    func cancelChanges() {
        stickersContainerView.isHidden = true
        tabBar.isHidden = false
        
        for _ in 0..<lastAttachments.count {
            overlayingStickerImageView.removeLast()
        }
        
        updateNavBarState()
    }
    
    func applyChanges() {
        stickersContainerView.isHidden = true
        tabBar.isHidden = false
        lastAttachments = []
        updateNavBarState()
    }
}
