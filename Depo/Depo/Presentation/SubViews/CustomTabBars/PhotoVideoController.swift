//
//  PhotoVideoController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import UIKit

// TODO: items storage with remotes

// TODO: CheckBoxViewDelegate
// TODO: video controller
// TODO: navigation bar appear (we have "setTitle("")" )
// TODO: items operations (progress)
// TODO: clear code -

final class PhotoVideoController: BaseViewController, NibInit, SegmentedChildController {

    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
    }
    
    private weak var contentSliderTopY: NSLayoutConstraint?
    private weak var contentSliderH: NSLayoutConstraint?
    private var refresherY: CGFloat = 0
    private let showOnlySyncItemsCheckBoxHeight: CGFloat = 44
    
    
    private let contentSlider: LBAlbumLikePreviewSliderViewController = {
        let sliderModuleConfigurator = LBAlbumLikePreviewSliderModuleInitializer()
        let sliderPresenter = LBAlbumLikePreviewSliderPresenter()
        sliderModuleConfigurator.initialise(inputPresenter: sliderPresenter)
        return sliderModuleConfigurator.lbAlbumLikeSliderVC
    }()
    
    private let scrolliblePopUpView = ViewForPopUp()
    private let showOnlySyncItemsCheckBox = CheckBoxView.initFromXib()
    
    private let refresher = UIRefreshControl()
    private var editingTabBar: BottomSelectionTabBarViewController?
    private var dataSource = PhotoVideoDataSource()
    
    private lazy var cancelSelectionButton = UIBarButtonItem(
        title: TextConstants.cancelSelectionButtonTitle,
        font: .TurkcellSaturaDemFont(size: 19.0),
        target: self,
        selector: #selector(onCancelSelectionButton))
    
    private lazy var threeDotsButton = UIBarButtonItem(
        image: Images.threeDots,
        style: .plain,
        target: self,
        action: #selector(onThreeDotsButton))
    
    private lazy var searchButton = UIBarButtonItem(
        image: Images.search,
        style: .plain,
        target: self,
        action: #selector(onSearchButton))
    
    private lazy var alert: AlertFilesActionsSheetPresenter = {
        let alert = AlertFilesActionsSheetPresenterModuleInitialiser().createModule()
        alert.basePassingPresenter = self
        return alert
    }()
    
    
    private let bottomBarPresenter = BottomSelectionTabBarPresenter()
    private let analyticsManager: AnalyticsService = factory.resolve()
    
    private let photoVideoBottomBarConfig = EditingBarConfig(
        elementsConfig:  [.share, .download, .sync, .addToAlbum, .delete], 
        style: .blackOpaque, tintColor: nil)
    
    private lazy var sectionChanges = [() -> Void]()
    private lazy var objectChanges = [() -> Void]()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<MediaItem> = {
        let fetchRequest: NSFetchRequest = MediaItem.fetchRequest()
        let sortDescriptor1 = NSSortDescriptor(key: #keyPath(MediaItem.creationDateValue), ascending: false)
        //        let sortDescriptor2 = NSSortDescriptor(key: #keyPath(MediaItem.nameValue), ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        // TODO: device isIpad
        if UI_USER_INTERFACE_IDIOM() == .pad {
            fetchRequest.fetchBatchSize = 50
        } else {
            fetchRequest.fetchBatchSize = 20
        }
        
        //fetchRequest.relationshipKeyPathsForPrefetching = [#keyPath(PostDB.id)]
        let context = CoreDataStack.default.mainContext
        let frController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: #keyPath(MediaItem.monthValue), cacheName: nil)
        frController.delegate = self
        return frController
    }()
    
    private var selectedObjects: [WrapData] {
        return dataSource.selectedIndexPaths.map { indexPath in
            let object = fetchedResultsController.object(at: indexPath)
            return WrapData(mediaItem: object)
        }
    }
    
    private var fetchedObjects: [WrapData] {
        return fetchedResultsController.fetchedObjects?.map { object in
            return WrapData(mediaItem: object)
        } ?? []
    }
    
    // MARK: - life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupEdittingBar()
        setupPullToRefresh()
        setupCollectionView()
        performFetch()
        
        setupViewForPopUp()
        
        /// call only after setupViewForPopUp()
        setupShowOnlySyncItemsCheckBox()
        
        /// call only after setupShowOnlySyncItemsCheckBox()
        setupSlider()
        
        
        setRightBarButtonItems([threeDotsButton, searchButton], animated: false)
        
        CardsManager.default.addViewForNotification(view: scrolliblePopUpView)
        CardsManager.default.updateAllProgressesInCardsForView(view: scrolliblePopUpView)
        
        
        
        
        needShowTabBar = true
        floatingButtonsArray.append(contentsOf: [.floatingButtonTakeAPhoto, .floatingButtonUpload, .floatingButtonCreateAStory, .floatingButtonCreateAlbum])
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCellSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCellSize()
        editingTabBar?.view.layoutIfNeeded()
        scrolliblePopUpView.isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrolliblePopUpView.isActive = false
    }
    
    deinit {
        CardsManager.default.removeViewForNotification(view: scrolliblePopUpView)
    }

    
    // MARK: - setup
    
    private func setupEdittingBar() {
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        bottomBarPresenter.basePassingPresenter = self
        let botvarBarVC = bottomBarVCmodule.setupModule(config: photoVideoBottomBarConfig, settablePresenter: bottomBarPresenter)
        self.editingTabBar = botvarBarVC
    }
    
    private func setupPullToRefresh() {
        //refresher.tintColor = ColorConstants.whiteColor
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.addSubview(refresher)
    }
    
    private func setupCollectionView() {
        collectionView.register(nibCell: PhotoVideoCell.self)
        collectionView.register(nibSupplementaryView: CollectionViewSimpleHeaderWithText.self, kind: UICollectionElementKindSectionHeader)        
        //        collectionView.alwaysBounceVertical = true
        //        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
    }
    
    private func performFetch() {
        try? fetchedResultsController.performFetch()
        collectionView.reloadData()
        contentSlider.reloadAllData()
    }
    
    private func updateCellSize() {
        _ = collectionView.saveAndGetItemSize(for: 4)
    }
    
    private func setupViewForPopUp() {
        scrolliblePopUpView.delegate = self
        scrolliblePopUpView.isEnable = true
        scrolliblePopUpView.addNotPermittedPopUpViewTypes(types: [.waitingForWiFi, .autoUploadIsOff, .freeAppSpace, .freeAppSpaceLocalWarning])
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        collectionView.addSubview(scrolliblePopUpView)
        
        scrolliblePopUpView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraintsArray = [NSLayoutConstraint]()
        contentSliderTopY = NSLayoutConstraint(item: scrolliblePopUpView, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: 0)
        constraintsArray.append(contentSliderTopY!)
        constraintsArray.append(NSLayoutConstraint(item: scrolliblePopUpView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: scrolliblePopUpView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        contentSliderH = NSLayoutConstraint(item: scrolliblePopUpView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        constraintsArray.append(contentSliderH!)
        
        NSLayoutConstraint.activate(constraintsArray)
    }
    
    private func setupSlider() {
        let sliderController = contentSlider
        
        let height = scrolliblePopUpView.frame.height + BaseFilesGreedViewController.sliderH + showOnlySyncItemsCheckBoxHeight
        
        let subView = UIView(frame: CGRect(x: 0, y: -height, width: collectionView.frame.width, height: BaseFilesGreedViewController.sliderH))
        subView.addSubview(sliderController.view)
        
        if let yConstr = self.contentSliderTopY {
            yConstr.constant = -height
        }
        collectionView.updateConstraints()
        
        collectionView.contentInset = UIEdgeInsets(top: height, left: 0, bottom: 25, right: 0)
        collectionView.addSubview(subView)
        sliderController.view.frame = subView.bounds
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let relatedView = showOnlySyncItemsCheckBox
        
        var constraintsArray = [NSLayoutConstraint]()
        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .top, relatedBy: .equal, toItem: relatedView, attribute: .bottom, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: BaseFilesGreedViewController.sliderH))
        
        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .left, relatedBy: .equal, toItem: subView, attribute: .left, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .top, relatedBy: .equal, toItem: subView, attribute: .top, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .right, relatedBy: .equal, toItem: subView, attribute: .right, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .bottom, relatedBy: .equal, toItem: subView, attribute: .bottom, multiplier: 1, constant: 0))
        
        NSLayoutConstraint.activate(constraintsArray)
        
        refresherY = -height + 30
        updateRefresher()
    }
    
    private func setupShowOnlySyncItemsCheckBox() {
        let checkBox = showOnlySyncItemsCheckBox
        checkBox.delegate = self
        collectionView.addSubview(checkBox)
        
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraintsArray = [NSLayoutConstraint]()
        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .top, relatedBy: .equal, toItem: scrolliblePopUpView, attribute: .bottom, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: showOnlySyncItemsCheckBoxHeight))
        
        NSLayoutConstraint.activate(constraintsArray)
    }
    
    // MARK: - Selectors
    
    @objc private func refreshData() {
        performFetch()
        refresher.endRefreshing()
    } 
    
    @objc private func onCancelSelectionButton() {
        stopEditingMode()
    }
    
    // TODO: - optmize -
    @objc private func onThreeDotsButton() {
        if dataSource.isSelectingMode {
            let items = selectedObjects
            ThreeDotMenuManager.actionsForImageItems(items) { [weak self] types in
                // TODO: - check on iPad without sender -
                self?.alert.show(with: types, for: items, presentedBy: nil, onSourceView: nil, viewController: self)
            }
        } else {
            self.alert.show(with: [.select], for: [], presentedBy: nil, onSourceView: nil, viewController: self)
        }
    }
    
    @objc private func onSearchButton() {
        showSearchScreen(output: self)
    }
    
    private func showSearchScreen(output: UIViewController?) {
        let router = RouterVC()
        let controller = router.searchView(output: output as? SearchModuleOutput)
        output?.navigationController?.delegate = controller as? BaseViewController
        controller.transitioningDelegate = output as? UIViewControllerTransitioningDelegate
        router.pushViewController(viewController: controller)
    }
    
    // MARK: - Editing Mode
    
    private func startEditingMode(at indexPath: IndexPath?) {
        guard !dataSource.isSelectingMode else {
            return
        }
        ///history: parent?.navigationItem.leftBarButtonItem = cancelSelectionButton
        dataSource.isSelectingMode = true
        if let indexPath = indexPath {
            dataSource.selectedIndexPaths.insert(indexPath)
        }
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        onChangeSelectedItemsCount(selectedItemsCount: dataSource.selectedIndexPaths.count)
        setLeftBarButtonItems([cancelSelectionButton], animated: true)
        setRightBarButtonItems([threeDotsButton], animated: true)
    }
    
    private func stopEditingMode() {
        dataSource.isSelectingMode = false
        dataSource.selectedIndexPaths.removeAll()
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        bottomBarPresenter.dismissWithNotification()
        setLeftBarButtonItems(nil, animated: true)
        setTitle("")
        setRightBarButtonItems([threeDotsButton, searchButton], animated: true)
    }
    
    // MARK: - helpers
    
    private func onChangeSelectedItemsCount(selectedItemsCount: Int) {
        setupNewBottomBarConfig()
        
        if selectedItemsCount == 0 {
            threeDotsButton.isEnabled = false
            bottomBarPresenter.dismissWithNotification()
        } else {
            threeDotsButton.isEnabled = true
            bottomBarPresenter.show(animated: true, onView: nil)
        }
        
        setTitle("\(selectedItemsCount) \(TextConstants.accessibilitySelected)")
    }
    
    private func setupNewBottomBarConfig() {
        bottomBarPresenter.setupTabBarWith(items: selectedObjects, originalConfig: photoVideoBottomBarConfig)
    }
    
    private func showDetail(at indexPath: IndexPath) {
        // TODO: - trackClickOnPhotoOrVideo(isPhoto: false) -
        trackClickOnPhotoOrVideo(isPhoto: true)
        
        let currentMediaItem = fetchedResultsController.object(at: indexPath)
        let currentObject = WrapData(mediaItem: currentMediaItem)
        
        let router = RouterVC()
        let controller = router.filesDetailViewController(fileObject: currentObject, items: fetchedObjects)
        let nController = NavigationController(rootViewController: controller)
        router.presentViewController(controller: nController)
    }
    
    private func select(cell: PhotoVideoCell, at indexPath: IndexPath) {
        let isSelectedCell = dataSource.selectedIndexPaths.contains(indexPath)
        
        if isSelectedCell {
            dataSource.selectedIndexPaths.remove(indexPath)
        } else {
            dataSource.selectedIndexPaths.insert(indexPath)
        }
        
        cell.set(isSelected: !isSelectedCell, isSelectionMode: dataSource.isSelectingMode, animated: true)
        onChangeSelectedItemsCount(selectedItemsCount: dataSource.selectedIndexPaths.count)
    }
    
    private func trackClickOnPhotoOrVideo(isPhoto: Bool) {
        analyticsManager.trackCustomGAEvent(eventCategory: .functions, eventActions: .click, eventLabel: isPhoto ? .clickPhoto : .clickVideo)
    }
    
    func updateRefresher() {
        guard let refresherView = refresher.subviews.first else {
            return
        }
        refresherView.center = CGPoint(x: refresherView.center.x, y: refresherY)
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoVideoController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(cell: PhotoVideoCell.self, for: indexPath)
    }
}

// MARK: - PhotoVideoCellDelegate
extension PhotoVideoController: PhotoVideoCellDelegate {
    func photoVideoCellOnLongPressBegan(at indexPath: IndexPath) {
        startEditingMode(at: indexPath)
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoVideoController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoVideoCell else {
            return
        }
        cell.delegate = self
        cell.indexPath = indexPath
        
        let object = fetchedResultsController.object(at: indexPath)
        let wraped = WrapData(mediaItem: object)
        cell.setup(with: wraped)
        
        let isSelectedCell = dataSource.selectedIndexPaths.contains(indexPath)
        cell.set(isSelected: isSelectedCell, isSelectionMode: dataSource.isSelectingMode, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PhotoVideoCell else {
            return
        }
        
        if dataSource.isSelectingMode {
            select(cell: cell, at: indexPath)
        } else {
            showDetail(at: indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       let view = collectionView.dequeue(supplementaryView: CollectionViewSimpleHeaderWithText.self, kind: kind, for: indexPath)
        
        let object = fetchedResultsController.object(at: indexPath)
        if let date = object.creationDateValue as Date? {
            let df = DateFormatter()
            df.dateStyle = .medium
            let title = df.string(from: date)
            view.setText(text: title)
        } else {
            view.setText(text: "nil")
        }
        
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PhotoVideoController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        ///return CGSize(width: collectionView.contentSize.width, height: 50)
        return CGSize(width: 0, height: 50)
    }
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //        
    //        return CGSize(width: 200, height: 200)
    //    }
}

// MARK: - NSFetchedResultsControllerDelegate
/// https://github.com/jessesquires/JSQDataSourcesKit/blob/develop/Source/FetchedResultsDelegate.swift
/// https://gist.github.com/nor0x/c48463e429ba7b053fff6e277c72f8ec
extension PhotoVideoController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        sectionChanges.removeAll()
        objectChanges.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let section = IndexSet(integer: sectionIndex)
        
        sectionChanges.append { [unowned self] in
            switch type {
            case .insert:
                self.collectionView.insertSections(section)
            case .delete:
                self.collectionView.deleteSections(section)
            default:
                break
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.insertItems(at: [indexPath])
                }
            }
        case .delete:
            if let indexPath = indexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
        case .update:
            if let indexPath = indexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                self.objectChanges.append { [unowned self] in
                    self.collectionView.moveItem(at: indexPath, to: newIndexPath)
                }
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({ [weak self] in  
            self?.objectChanges.forEach { $0() }
            ///check: self?.sectionChanges.forEach { $0() }
        }, completion: { [weak self] _ in
            
            self?.collectionView.performBatchUpdates({
                self?.sectionChanges.forEach { $0() }
            }, completion: { _ in 
                self?.reloadSupplementaryViewsIfNeeded()
            })
        })
    }
    
    private func reloadSupplementaryViewsIfNeeded() {
        if !sectionChanges.isEmpty {
            collectionView.reloadData()
        }
    }

}

//extension PhotoVideoController: SegmentedControllerDelegate {
//}

// MARK: - BaseItemInputPassingProtocol
extension PhotoVideoController: BaseItemInputPassingProtocol {
    
    var selectedItems: [BaseDataSourceItem] {
        return selectedObjects
    }
    
    func stopModeSelected() {
        stopEditingMode()
    }
    
    func selectModeSelected() {
        startEditingMode(at: nil)
    }
    
    func operationFinished(withType type: ElementTypes, response: Any?) {}
    func operationFailed(withType type: ElementTypes) {}
    func selectAllModeSelected() {}
    func deSelectAll() {}
    func printSelected() {}
    func changeCover() {}
    func deleteFromFaceImageAlbum(items: [BaseDataSourceItem]) {}
}

// MARK: - ViewForPopUpDelegate
extension PhotoVideoController: ViewForPopUpDelegate {
    func onUpdateViewForPopUpH(h: CGFloat) {
        let originalPoint = collectionView.contentOffset
        let sliderH = contentSlider.view.frame.height
        let checkBoxH = showOnlySyncItemsCheckBox.frame.height
        let calculatedH = h + sliderH + checkBoxH
        
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            if let yConstr = self.contentSliderTopY {
                yConstr.constant = -calculatedH
            }
            if let hConstr = self.contentSliderH {
                hConstr.constant = h
            }
            
            self.view.layoutIfNeeded()
            self.collectionView.contentInset = UIEdgeInsets(top: calculatedH, left: 0, bottom: 25, right: 0)
        }) { [weak self] (flag) in
            guard let `self` = self else {
                return
            }
            
            if originalPoint.y > 1.0{
                self.collectionView.contentOffset = originalPoint
            } else {
                self.collectionView.contentOffset = CGPoint(x: 0.0, y: -self.collectionView.contentInset.top)
            }
        }
        
        refresherY = -calculatedH + 30
        updateRefresher()
    }
}

// MARK: - CheckBoxViewDelegate
extension PhotoVideoController: CheckBoxViewDelegate {
    func checkBoxViewDidChangeValue(_ value: Bool) {
//        if value {
//            filtersByDefault = filters
//            filters = filters.filter { type -> Bool in
//                switch type {
//                case .localStatus(_):
//                    return false
//                default:
//                    return true
//                }
//            }
//            filters.append(.localStatus(.nonLocal))            
//        } else {
//            filters = filtersByDefault
//        }
//        dataSource.originalFilters = filters
//        reloadData()
    }
}
