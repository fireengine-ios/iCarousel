//
//  CreateCollageSelectionSegmentedController.swift
//  Lifebox
//
//  Created by Ozan Salman on 6.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit
import Reachability

protocol CreateCollageSelectionSegmentedControllerDelegate {
    func selectionStateDidChange(_ selectionState: CreateCollagePhotoSelectionState)
    func didSelectItem(_ selectedItem: SearchItemResponse)
    func didDeselectItem(_ deselectItem: SearchItemResponse)
    func allDeselectItem(selectedCount: Int)
}

final class CreateCollageSelectionSegmentedController: BaseViewController, ErrorPresenter {

    var selectedItems = [SearchItemResponse]()
    
    var selectionState = CreateCollagePhotoSelectionState.selecting {
        didSet {
            delegates.invoke { delegate in
                delegate.selectionStateDidChange(selectionState)
            }
        }
    }
    
    private let selectionControllerPageSize = Device.isIpad ? 200 : 100
    private var currentSelectingCount = 0
    private let selectingLimit = 5
    private var selectablePhotoCount: Int = 0
    private var segmentedViewControllers: [UIViewController] = []
    private var delegates = MulticastDelegate<CreateCollageSelectionSegmentedControllerDelegate>()
    private var collageTemplate: CollageTemplateElement?
    let router = RouterVC()
    
    private lazy var albumsTabIndex: Int = {
        if let index = segmentedViewControllers.firstIndex(of: albumsVC) {
            return index
        }
        assertionFailure("there is no albumsVC in segmentedViewControllers. check func setupScreenWithSelectingLimit. It was: index = 1")
        return 0
    }()
    
    private lazy var albumsVC = CreateCollageAlbumSelectionViewController(title: TextConstants.albumsTitle, delegate: self)
    
    private lazy var closeAlbumButton = UIBarButtonItem(image: NavigationBarImage.back.image,
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(onCloseAlbum))
    
    private lazy var closeSelfButton = UIBarButtonItem(image: NavigationBarImage.back.image,
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(closeSelf))
    
    init(collageTemplate: CollageTemplateElement) {
        self.collageTemplate = collageTemplate
        selectablePhotoCount = collageTemplate.shapeCount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        //navigationItem.title = String(format: "Select Photo", 0)
        navigationItem.leftBarButtonItem = closeSelfButton
    }
    
    override func loadView() {
        self.view = CreateCollageSelectionSegmentedView()
    }
    
    private lazy var vcView: CreateCollageSelectionSegmentedView = {
        if let view = self.view as? CreateCollageSelectionSegmentedView {
            return view
        } else {
            assertionFailure("override func loadView")
            return CreateCollageSelectionSegmentedView()
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTitle()
        setupScreenWithSelectingLimit(selectingLimit)
        trackScreen()
        vcView.actionButton.addTarget(self, action: #selector(actionButtonTap), for: .touchUpInside)
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
        let allPhotosDataSource = CreateCollageAllPhotosSelectionDataSource(pageSize: selectionControllerPageSize)
        let allPhotosVC = CreateCollagePhotoSelectionController(title: TextConstants.actionSheetPhotos,
                                                   selectingLimit: selectingLimit,
                                                   delegate: self,
                                                   dataSource: allPhotosDataSource)
        
        let favoriteDataSource = CreateCollageFavoritePhotosSelectionDataSource(pageSize: selectionControllerPageSize)
        let favoritePhotosVC = CreateCollagePhotoSelectionController(title: TextConstants.homeButtonFavorites,
                                                        selectingLimit: selectingLimit,
                                                        delegate: self,
                                                        dataSource: favoriteDataSource)
        
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
        if selectedItems.count > 0 &&  selectedItems.count != selectablePhotoCount{
            allDeselectItems()
            selectedItems.removeAll()
            updateTitle()
        }
        if selectedItems.count == selectablePhotoCount {
            dismiss(animated: true, completion: {
                print("Collage Screen")
                let imagesUrls = self.selectedItems.compactMap({ $0.metadata?.mediumUrl })
                let ids = self.selectedItems.compactMap({ $0.uuid })
                let vc = self.router.createCollagePreview(collageTemplate: self.collageTemplate!, selectedItems: self.selectedItems)
                self.router.pushViewController(viewController: vc, animated: false)
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
extension CreateCollageSelectionSegmentedController: CreateCollagePhotoSelectionControllerDelegate {
    
    func selectionController(_ controller: CreateCollagePhotoSelectionController, didSelectItem item: SearchItemResponse) {
        delegates.invoke { delegate in
            delegate.didSelectItem(item)
        }
        selectedItems.append(item)
        updateTitle()
        let selectedCount = selectedItems.count
        let isReachedLimit = (selectedCount == selectablePhotoCount)
        if isReachedLimit {
            selectionState = .ended
        } else {
            selectionState = .selecting
        }
    }
    
    func selectionController(_ controller: CreateCollagePhotoSelectionController, didDeselectItem item: SearchItemResponse) {
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
        vcView.selectedTextLabel.text = "\(selectedItems.count) - \(selectablePhotoCount) Selected"
        if selectedItems.count == selectablePhotoCount {
            vcView.actionButton.setTitle(TextConstants.ok, for: .normal)
            selectionState = .ended
        } else {
            vcView.actionButton.setTitle(TextConstants.cancel, for: .normal)
            selectionState = .selecting
        }
    }
}

// MARK: - InstapickAlbumSelectionDelegate
extension CreateCollageSelectionSegmentedController: CreateCollageAlbumSelectionDelegate {
    func onSelectAlbum(_ album: AlbumItem) {
        let dataSource = CreateCollageAlbumPhotosSelectionDataSource(pageSize: selectionControllerPageSize, albumUuid: album.uuid)
        let albumSelectionVC = CreateCollagePhotoSelectionController(title: album.name ?? "",
                                                           selectingLimit: selectingLimit,
                                                           delegate: self,
                                                           dataSource: dataSource)
        delegates.add(albumSelectionVC)
        replaceControllerAtAlbumsTab(with: albumSelectionVC)
    }
}

