//
//  PhotoPrintSelectionSegmentedController.swift
//  Depo
//
//  Created by Ozan Salman on 24.07.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit
import Reachability

protocol PhotoPrintSelectionSegmentedControllerDelegate {
    func selectionStateDidChange(_ selectionState: PhotoPrintPhotoSelectionState)
    func didSelectItem(_ selectedItem: SearchItemResponse)
    func didDeselectItem(_ deselectItem: SearchItemResponse)
    func allDeselectItem(selectedCount: Int)
}

enum PrintPhotoSelectType {
    case newPhotoSelection
    case changePhotoSelection
}

final class PhotoPrintSelectionSegmentedController: BaseViewController, ErrorPresenter {

    var selectedItems = [SearchItemResponse]()
    var selectedItemsDefault = [SearchItemResponse]()
    var selectedItemsChangePhoto = [SearchItemResponse]()
    
    var selectionState = PhotoPrintPhotoSelectionState.selecting {
        didSet {
            delegates.invoke { delegate in
                delegate.selectionStateDidChange(selectionState)
            }
        }
    }
    
    private var photoSelectType = PrintPhotoSelectType.newPhotoSelection
    private let selectionControllerPageSize = Device.isIpad ? 200 : 100
    private var currentSelectingCount = 0
    private let selectingLimit = 20
    private var selectablePhotoCount: Int = NumericConstants.photoPrintSelectablePhoto
    private var segmentedViewControllers: [UIViewController] = []
    private var delegates = MulticastDelegate<PhotoPrintSelectionSegmentedControllerDelegate>()
    private var collageTemplate: CollageTemplateElement?
    private let router = RouterVC()
    private var selectedItemFromCollagePreview: SearchItemResponse?
    private var selectedItemIndexFromCollagePreview: Int = -1
    private var popupShowing: Bool? = true
    
    private lazy var albumsTabIndex: Int = {
        if let index = segmentedViewControllers.firstIndex(of: albumsVC) {
            return index
        }
        assertionFailure("there is no albumsVC in segmentedViewControllers. check func setupScreenWithSelectingLimit. It was: index = 1")
        return 0
    }()
    
    private lazy var albumsVC = PhotoPrintAlbumSelectionViewController(title: TextConstants.albumsTitle, delegate: self)
    
    private lazy var closeAlbumButton = UIBarButtonItem(image: NavigationBarImage.back.image,
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(onCloseAlbum))
    
    private lazy var closeSelfButton = UIBarButtonItem(image: NavigationBarImage.back.image,
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(closeSelf))
    
    init(selectedPhotos: [SearchItemResponse] = [], selectedPhotoIndex: Int? = nil, popupShowing: Bool? = nil) {
        if selectedPhotos.count > 0 {
            self.selectedItemIndexFromCollagePreview = selectedPhotoIndex ?? 0
            self.selectedItemsDefault = selectedPhotos
            selectablePhotoCount = 1
            self.photoSelectType = .changePhotoSelection
            self.popupShowing = popupShowing
        } else {
            self.photoSelectType = .newPhotoSelection
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        navigationItem.leftBarButtonItem = closeSelfButton
    }
    
    override func loadView() {
        self.view = PhotoPrintSelectionSegmentedView()
    }
    
    private lazy var vcView: PhotoPrintSelectionSegmentedView = {
        if let view = self.view as? PhotoPrintSelectionSegmentedView {
            return view
        } else {
            assertionFailure("override func loadView")
            return PhotoPrintSelectionSegmentedView()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        setupScreenWithSelectingLimit(selectingLimit)
        trackScreen()
        vcView.actionButton.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)
        setTitle(withString: localized(.createCollageSelectPhotoMainTitle))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    private func trackScreen() {
        AnalyticsService.sendNetmeraEvent(event: NetmeraEvents.Screens.PhotoPickPhotoSelectionScreen())
        let analyticsService: AnalyticsService = factory.resolve()
        analyticsService.logScreen(screen: .photoPickPhotoSelection)
        analyticsService.trackDimentionsEveryClickGA(screen: .photoPickPhotoSelection)
    }
    
    private func setupScreenWithSelectingLimit(_ selectingLimit: Int) {
        let allPhotosDataSource = PhotoPrintAllPhotosSelectionDataSource(pageSize: selectionControllerPageSize)
        let allPhotosVC = PhotoPrintPhotoSelectionController(title: TextConstants.actionSheetPhotos,
                                                   selectingLimit: selectingLimit,
                                                   delegate: self,
                                                   dataSource: allPhotosDataSource,
                                                   popupShowing: popupShowing)
        
        let favoriteDataSource = PhotoPrintFavoritePhotosSelectionDataSource(pageSize: selectionControllerPageSize)
        let favoritePhotosVC = PhotoPrintPhotoSelectionController(title: TextConstants.homeButtonFavorites,
                                                        selectingLimit: selectingLimit,
                                                        delegate: self,
                                                        dataSource: favoriteDataSource,
                                                                  popupShowing: false)
        
        segmentedViewControllers = [allPhotosVC, albumsVC, favoritePhotosVC]
        
        delegates.add(allPhotosVC)
        delegates.add(favoritePhotosVC)
        
        DispatchQueue.toMain {
            self.selectController(at: 0)
            self.setupSegmentedControl()
        }
    }
    
    private func setupSegmentedControl() {
        assert(!segmentedViewControllers.isEmpty, "should not be empty")
        for (index, controller) in segmentedViewControllers.enumerated() {
            vcView.segmentedControl.insertSegment(withTitle: controller.title ?? "", tag: index, width: 112)
        }
        vcView.segmentedControl.renderSegmentButtons(segment: 0)
        vcView.segmentedControl.action = controllerDidChange
    }
    
    private func controllerDidChange(_ tag: Int) {
        selectController(at: tag)
    }
    
    @objc private func closeSelf() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func actionButtonTap() {
        switch photoSelectType {
        case .newPhotoSelection:
            if selectedItems.count > 0 &&  selectedItems.count != selectablePhotoCount{
                let vc = PhotoPrintMissingPhotoPopup.with(selectedPhotoCount: selectedItems.count, selectedPhotos: selectedItems)
                vc.openWithBlur()
            }
            if selectedItems.count == selectablePhotoCount {
                dismiss(animated: false, completion: {
                    let vc = self.router.photoPrintViewController(selectedPhotos: self.selectedItems)
                    self.router.pushViewController(viewController: vc)
                })
            }
        case .changePhotoSelection:
            if selectedItems.count > 0 &&  selectedItems.count != selectablePhotoCount{
                allDeselectItems()
                updateTitle()
            }
            dismiss(animated: true, completion: {
                PhotoPrintConstants.selectedChangePhotoItems = self.selectedItemsChangePhoto
                self.router.popViewController()
            })
        }
    }
    
    private func selectController(at selectedIndex: Int) {
        guard selectedIndex < segmentedViewControllers.count else {
            assertionFailure()
            return
        }
        children.forEach { $0.removeFromParentVC() }
        add(childController: segmentedViewControllers[selectedIndex])
        updateLeftBarButtonItem(selectedIndex: selectedIndex)
    }

    private func updateLeftBarButtonItem(selectedIndex: Int) {
        let isAlbumsTabOpened = (selectedIndex == albumsTabIndex)
        let isAnyAlbumOpened = (segmentedViewControllers[albumsTabIndex] != albumsVC)
        
        if isAlbumsTabOpened, isAnyAlbumOpened {
            navigationItem.leftBarButtonItem = closeAlbumButton
        } else {
            navigationItem.leftBarButtonItem = closeSelfButton
        }
    }
    
    private func add(childController: UIViewController) {
        addChild(childController)
        childController.view.frame = vcView.containerView.bounds
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        vcView.containerView.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
    
    @objc private func onCloseAlbum() {
        replaceControllerAtAlbumsTab(with: albumsVC)
    }
    
    private func replaceControllerAtAlbumsTab(with controller: UIViewController) {
        segmentedViewControllers.remove(at: albumsTabIndex)
        segmentedViewControllers.insert(controller, at: albumsTabIndex)
        selectController(at: albumsTabIndex)
    }
}

// MARK: - PhotoSelectionControllerDelegate
extension PhotoPrintSelectionSegmentedController: PhotoPrintPhotoSelectionControllerDelegate {
    
    func selectionController(_ controller: PhotoPrintPhotoSelectionController, didSelectItem item: SearchItemResponse) {
        
        switch photoSelectType {
        case .newPhotoSelection:
            delegates.invoke { delegate in
                delegate.didSelectItem(item)
            }
            selectedItems.append(item)
        case .changePhotoSelection:
            delegates.invoke { delegate in
                delegate.didSelectItem(item)
            }
            //selectedItems.removeAll()
            selectedItemsChangePhoto.append(item)
            selectedItems.append(item)
//            selectedItemsDefault.remove(at: selectedItemIndexFromCollagePreview)
//            selectedItemsDefault.insert(contentsOf: selectedItems, at: selectedItemIndexFromCollagePreview)
        }
        
        updateTitle()
        let selectedCount = selectedItems.count
        let isReachedLimit = (selectedCount == selectablePhotoCount)
        if isReachedLimit {
            selectionState = .ended
        } else {
            selectionState = .selecting
        }
    }
    
    func selectionController(_ controller: PhotoPrintPhotoSelectionController, didDeselectItem item: SearchItemResponse) {
        delegates.invoke { delegate in
            delegate.didDeselectItem(item)
        }
        for index in (0..<selectedItems.count).reversed() where selectedItems[index] == item {
            selectedItems.remove(at: index)
        }
        selectionState = .selecting
        updateTitle()
    }
    
    private func allDeselectItems() {
        delegates.invoke { delegate in
            delegate.allDeselectItem(selectedCount: selectedItems.count)
        }
    }
    
    private func updateTitle() {
        switch photoSelectType {
        case .newPhotoSelection:
            if selectedItems.count == 0 {
                updateBottomTabbarLayout(value: false)
                vcView.selectedTextLabel.text = "\(selectedItems.count)/\(selectablePhotoCount)"
                return
            }
            vcView.selectedTextLabel.text = "\(selectedItems.count)/\(selectablePhotoCount)"
            updateBottomTabbarLayout(value: true)
            selectionState = selectedItems.count == selectablePhotoCount ? .ended : .selecting
        case .changePhotoSelection:
            if selectedItems.count == 0 {
                updateBottomTabbarLayout(value: false)
                vcView.selectedTextLabel.text = "\(selectedItems.count)/\(selectablePhotoCount)"
                return
            }
            vcView.selectedTextLabel.text = "\(selectedItems.count)/\(selectablePhotoCount)"
            updateBottomTabbarLayout(value: true)
            selectionState = selectedItems.count == selectablePhotoCount ? .ended : .selecting
        }
    }
    
    private func updateBottomTabbarLayout(value: Bool = true) {
        if value {
            vcView.subViewForInfoHeightConstraint?.constant = 130
            vcView.subViewForInfoHeightConstraint?.isActive = true
            vcView.actionButton.isHidden = false
        } else {
            vcView.subViewForInfoHeightConstraint?.constant = 90
            vcView.subViewForInfoHeightConstraint?.isActive = true
            vcView.actionButton.isHidden = true
        }
    }
}

// MARK: - InstapickAlbumSelectionDelegate
extension PhotoPrintSelectionSegmentedController: PhotoPrintAlbumSelectionDelegate {
    func onSelectAlbum(_ album: AlbumItem) {
        let dataSource = PhotoPrintAlbumPhotosSelectionDataSource(pageSize: selectionControllerPageSize, albumUuid: album.uuid)
        let albumSelectionVC = PhotoPrintPhotoSelectionController(title: album.name ?? "",
                                                           selectingLimit: selectingLimit,
                                                           delegate: self,
                                                           dataSource: dataSource,
                                                           popupShowing: false)
        delegates.add(albumSelectionVC)
        replaceControllerAtAlbumsTab(with: albumSelectionVC)
    }
}


