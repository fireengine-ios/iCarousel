//
//  BaseFilesGreedViewController.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BaseFilesGreedViewController: BaseViewController, BaseFilesGreedViewInput, CardsContainerViewDelegate {
    
    var output: BaseFilesGreedViewOutput!
    
    var navBarConfigurator = NavigationBarConfigurator()
    
    var refresher: UIRefreshControl!
    
    var cancelSelectionButton: UIBarButtonItem?
    
    var backAsCancelBarButton: UIBarButtonItem?
    
    var editingTabBar: BottomSelectionTabBarDrawerViewController?
    
    var isFavorites: Bool = false
    
    var mainTitle: String = ""
    
    var subTitle: String = ""
    
    var plusButtonType = String()
    
    var forYouControllerSection: ForYouSections?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var noFilesView: UIView!
    
    @IBOutlet weak var noFilesLabel: UILabel! {
        willSet {
            newValue.font = .appFont(.medium, size: 16)
            newValue.textColor = AppColor.label.color
            newValue.text = TextConstants.photosVideosViewNoPhotoTitleText
        }
    }
    
    @IBOutlet weak var noFilesImage: UIImageView!
    
    @IBOutlet weak var startCreatingFilesButton: BlueButtonWithNoFilesWhiteText!

    @IBOutlet weak var topBarContainer: UIView!
    
    @IBOutlet weak var noFilesTopLabel: UILabel?
    
    @IBOutlet weak var floatingHeaderContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var scrollIndicator: CustomScrollIndicator?
    @IBOutlet private weak var headerStackView: UIStackView!
    
    var cardsContainerView = CardsContainerView()
    var contentSlider: LBAlbumLikePreviewSliderViewController?
    weak var contentSliderTopY: NSLayoutConstraint?
    weak var contentSliderH: NSLayoutConstraint?
    
    var underNavBarBar: GridListTopBar?
    
    let conf = NavigationBarConfigurator()
    var refresherY: CGFloat = 0
    
    let underNavBarBarHeight: CGFloat = 53
    var calculatedUnderNavBarBarHeight: CGFloat = 0
    
    var isRefreshAllowed = true
    
    var status: ItemStatus = .active
    
    private lazy var countView: GridListCountView  = {
        let view = GridListCountView.initFromNib()
        view.delegate = self
        return view
    }()
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        collectionView!.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        refresher.tintColor = ColorConstants.whiteColor
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView!.addSubview(refresher)
        
        cancelSelectionButton = UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                                                font: .TurkcellSaturaDemFont(size: 19.0),
                                                target: self,
                                                selector: #selector(onCancelSelectionButton))
        
        backAsCancelBarButton = UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                                                font: .TurkcellSaturaDemFont(size: 19.0),
                                                target: self,
                                                selector: #selector(onBackButton))
        
        noFilesTopLabel?.text = TextConstants.folderEmptyText
        noFilesTopLabel?.textColor = AppColor.label.color
        noFilesTopLabel?.font = .appFont(.medium, size: 16)
        
        startCreatingFilesButton.setTitle(TextConstants.photosVideosViewNoPhotoButtonText, for: .normal)
        startCreatingFilesButton.titleLabel?.font = .appFont(.medium, size: 16)
        
        scrollIndicator?.changeHiddenState(to: true, animated: false)
        
        output.viewIsReady(collectionView: collectionView)
        NotificationCenter.default.addObserver(self,selector: #selector(loadData),name: .createOnlyOfficeDocumentsReloadData, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        editingTabBar?.view.layoutIfNeeded()
        
        if mainTitle != "" {
            subTitle = output.getSortTypeString()
        }
        
        if !StringConstants.onlyOfficeDocumentsFilter && segmentImage == .documents {
            loadData()
            StringConstants.onlyOfficeDocumentsFilter = true
        }
        
        output.viewWillAppear()
        
        if let searchController = navigationController?.topViewController as? SearchViewController {
            searchController.dismissController(animated: false)
        }
        cardsContainerView.isActive = true
        CardsManager.default.updateAllProgressesInCardsForView(view: cardsContainerView)
        output.needToReloadVisibleCells()
        configurateNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configurateViewForPopUp()
        output.updateThreeDotsButton()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        cardsContainerView.isActive = false
        super.viewDidDisappear(animated)
    }
    
    func configurateViewForPopUp() {
        CardsManager.default.addViewForNotification(view: cardsContainerView)
    }
    
    func configurateNavigationBar() {
        configureNavBarActions()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        output.viewWillDisappear()
        countView.removeFromSuperview()
    }
    
    deinit {
        CardsManager.default.removeViewForNotification(view: cardsContainerView)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - SearchBarButtonPressed
    
    
    
    func configureNavBarActions(isSelecting: Bool = false) {
        let search = NavBarWithAction(navItem: NavigationBarList().search, action: { [weak self] _ in
            self?.output.searchPressed(output: self)
        })
        
        let newStory = NavBarWithAction(navItem: NavigationBarList().plus, action: { [weak self] _ in
            self?.output.openCreateNewStory(output: self)
        })
        
        let newAlbum = NavBarWithAction(navItem: NavigationBarList().newAlbum, action: { [weak self] _ in
            self?.output.openCreateNewAlbum()
        })
        
        let upload = NavBarWithAction(navItem: NavigationBarList().plus, action: { [weak self] _ in
            self?.output.openUpload()
        })
        
        let createCollage = NavBarWithAction(navItem: NavigationBarList().plus, action: { [weak self] _ in
            self?.output.createCollage()
        })

        var rightActions: [NavBarWithAction] = []
        
        switch forYouControllerSection {
        case .collages:
            rightActions.append(createCollage)
        case .animations, .places, .hidden, .things, .favorites:
            rightActions.removeAll()
        case .albums:
            rightActions.append(newAlbum)
        case .story:
            rightActions.append(newStory)
        default:
            rightActions.removeAll()
        }
        
        if plusButtonType == "Folder" {
            //rightActions.append(upload)
            let search = NavBarWithAction(navItem: NavigationBarList().search, action: { [weak self] _ in
                self?.output.searchPressed(output: self)
            })
            
            let more = NavBarWithAction(navItem: NavigationBarList().newAlbum, action: { [weak self] _ in
                let menuItems = self?.floatingButtonsArray.map { buttonType in
                    AlertFilesAction(title: buttonType.title, icon: buttonType.image) { [weak self] in
                        self?.customTabBarController?.handleAction(buttonType.action)
                    }
                }
                
                let menu = AlertFilesActionsViewController()
                menu.configure(with: menuItems ?? [])
                menu.presentAsDrawer()
            })
            
            let rightActions: [NavBarWithAction] = [more, search]
            search.navItem.imageInsets.left = 28
            navBarConfigurator.configure(right: isSelecting ? [] : rightActions, left: [])
            
            let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
            navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
            navigationItem.title = ""
            return
        }
        
        search.navItem.imageInsets.left = 28
        
        rightActions.append(search)
        navBarConfigurator.configure(right: isSelecting ? [] : rightActions, left: [])
        
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
        navigationItem.title = ""
    }
    
    func configurateFreeAppSpaceActions(deleteAction: @escaping VoidHandler) {
        let delete = NavBarWithAction(navItem: NavigationBarList().delete) { _ in
            deleteAction()
        }
        
        let more = NavBarWithAction(navItem: NavigationBarList().more) { [weak self] _ in
            self?.output.moreActionsPressed(sender: NavigationBarList().more)
        }
        
        navBarConfigurator.configure(right: [more, delete], left: [])
        
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
        navigationItem.leftBarButtonItem = backAsCancelBarButton
    }
    
    func configurateFaceImagePeopleActions(showHideAction: @escaping VoidHandler) {
        let showHide = NavBarWithAction(navItem: NavigationBarList().showHide, action: { _ in
            showHideAction()
        })
        
        navBarConfigurator.configure(right: [showHide], left: [])
        
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }
    
    func configureFaceImageItemsPhotoActions() {
        let more = NavBarWithAction(navItem: NavigationBarList().more, action: { [weak self] _ in
            self?.output.moreActionsPressed(sender: NavigationBarList().more)
        })
        let rightActions: [NavBarWithAction] = [more]
        navBarConfigurator.configure(right: rightActions, left: [])
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }
    
    func configureCountView(isShown: Bool) {
        countView.removeFromSuperview()
        
        if isShown {
            headerStackView.addArrangedSubview(countView)
        }
    }
    
    func setCountView(selectedItemsCount: Int) {
        countView.setCountLabel(with: selectedItemsCount)
    }
    
    @IBAction func onStartCreatingFilesButton() {
        output.onStartCreatingPhotoAndVideos()
    }
    
    // MARK: PhotosAndVideosViewInput
    
    func setupInitialState() {
        setupViewForPopUp()
        if let unwrapedSlider = contentSlider {
            setupSlider(sliderController: unwrapedSlider)
        }
    }
    
    
    // MARK: In
    
    func getCollectionViewWidth() -> CGFloat {
        return collectionView.frame.size.width
    }
    
    @objc func loadData() {
        guard isRefreshAllowed else {
            return
        }
        if !output.isSelectionState() {
            output.onReloadData()
            contentSlider?.reloadAllData()
        } else {
            refresher.endRefreshing()
        }
    }
    
    func stopRefresher() {
        DispatchQueue.main.async {
            self.refresher.endRefreshing()
        }
    }
    
    func disableRefresh() {
        isRefreshAllowed = false
    }
    
    func enableRefresh() {
        isRefreshAllowed = true
    }
    
    func showCustomPopUpWithInformationAboutAccessToMediaLibrary() {
        UIApplication.showErrorAlert(message: TextConstants.photosVideosViewHaveNoPermissionsAllertText)
    }
    
    func setCollectionViewVisibilityStatus(visibilityStatus: Bool) {
        collectionView.isHidden = visibilityStatus
    }
    
    func startSelection(with numberOfItems: Int) {
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.leftBarButtonItem = cancelSelectionButton
        selectedItemsCountChange(with: numberOfItems)
        configureNavBarActions(isSelecting: true)
        underNavBarBar?.setSorting(enabled: false)
        configureCountView(isShown: true)
    }
    
    func stopSelection() {
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.leftBarButtonItem = nil
        
        configureNavBarActions(isSelecting: false)
        underNavBarBar?.setSorting(enabled: true)
        configureCountView(isShown: false)
    }
    
    func setThreeDotsMenu(active isActive: Bool) {
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.rightBarButtonItem?.isEnabled = isActive
        
        if let threeDotsItem = navigationItem.rightBarButtonItems?.first(where: {$0.accessibilityLabel == TextConstants.accessibilityMore}) {
            threeDotsItem.isEnabled = isActive
        }
    }
    
    func showNoFilesWith(text: String, image: UIImage, createFilesButtonText: String, needHideTopBar: Bool) {
        noFilesLabel.text = text
        noFilesImage.image = image
        startCreatingFilesButton.isHidden = createFilesButtonText.isEmpty
        startCreatingFilesButton.setTitle(createFilesButtonText, for: .normal)
        noFilesView.isHidden = false
        topBarContainer.isHidden = needHideTopBar
        
        let service = output.getRemoteItemsService()
        if service is FavouritesService {
            startCreatingFilesButton.isHidden = true
        }
    }
    
    func showNoFilesTop(text: String) {
        noFilesTopLabel?.text = text
        noFilesTopLabel?.isHidden = !cardsContainerView.viewsArray.isEmpty
        topBarContainer.isHidden = true
        floatingHeaderContainerHeightConstraint?.constant = 0
        view.layoutIfNeeded()
    }
    
    func hideNoFiles() {
        noFilesView.isHidden = true
        noFilesTopLabel?.isHidden = true
        topBarContainer.isHidden = false
        floatingHeaderContainerHeightConstraint?.constant = calculatedUnderNavBarBarHeight
        view.layoutIfNeeded()
    }
    
    func requestStarted() {
        backAsCancelBarButton?.isEnabled = false
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    func requestStopped() {
        backAsCancelBarButton?.isEnabled = true
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    @objc func onCancelSelectionButton() {
        output.onCancelSelection()
    }
    
    @objc func onBackButton() {
        RouterVC().popViewController()
    }
    
    func changeSortingRepresentation(sortType type: SortedRules) {
        if self.mainTitle != "" {
            self.setTitle(withString: self.mainTitle, andSubTitle: type.descriptionForTitle)
        }
    }
    
    func getCurrentSortRule() -> SortedRules {
        return output.getCurrentSortRule()
    }
    
    func getRemoteItemsService() -> RemoteItemsService {
        return output.getRemoteItemsService()
    }
    
    func getFolder() -> Item? {
        return output.getFolder()
    }
    
    func selectedItemsCountChange(with count: Int) {
        let title = String(count) + " " + TextConstants.accessibilitySelected
        setTitle(withString: title)
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.title = title
        
        setCountView(selectedItemsCount: count)
    }
    
    static let sliderH: CGFloat = 139
    
    private func setupSlider(sliderController: LBAlbumLikePreviewSliderViewController) {
        contentSlider = sliderController
        
        let height = cardsContainerView.frame.size.height + BaseFilesGreedViewController.sliderH
        
        let subView = UIView(frame: CGRect(x: 0, y: -height, width: collectionView.frame.size.width, height: BaseFilesGreedViewController.sliderH))
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
        
        let relatedView = cardsContainerView
        
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
        
        refresherY =  -height + 30
        updateRefresher()
    }
    
    //setupCardsView
    private func setupViewForPopUp() {
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        collectionView.addSubview(cardsContainerView)
        
        cardsContainerView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraintsArray = [NSLayoutConstraint]()
        contentSliderTopY = NSLayoutConstraint(item: cardsContainerView, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: 0)
        constraintsArray.append(contentSliderTopY!)
        constraintsArray.append(NSLayoutConstraint(item: cardsContainerView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: cardsContainerView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        contentSliderH = NSLayoutConstraint(item: cardsContainerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        constraintsArray.append(contentSliderH!)
        
        NSLayoutConstraint.activate(constraintsArray)
        cardsContainerView.delegate = self
    }
    
    // MARK: ViewForPopUpDelegate
    
    func onUpdateViewForPopUpH(h: CGFloat) {
        let originalPoint = collectionView.contentOffset
        var sliderH: CGFloat = 0
        if let slider = self.contentSlider {
            sliderH = sliderH + slider.view.frame.size.height
        }
        
        let calculatedH = h + sliderH
        
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
    
    func updateRefresher() {
        guard let refresherView = refresher.subviews.first else {
            return
        }
        refresherView.center = CGPoint(x: refresherView.center.x, y: refresherY)
    }
    
    func setupUnderNavBarBar(withConfig config: GridListTopBarConfig) {
        guard let unwrapedTopBar = underNavBarBar else {
            return
        }
        unwrapedTopBar.view.translatesAutoresizingMaskIntoConstraints = false
        unwrapedTopBar.setupWithConfig(config: config)
        topBarContainer.addSubview(unwrapedTopBar.view)
        
        setupUnderNavBarBarConstraints(underNavBarBar: unwrapedTopBar)
    }
    
    private func setupUnderNavBarBarConstraints(underNavBarBar: GridListTopBar) {
        let horisontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[topBar]-(0)-|",
                                                                   options: [], metrics: nil,
                                                                   views: ["topBar" : underNavBarBar.view])
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[topBar]",
                                                                 options: [], metrics: nil,
                                                                 views: ["topBar" : underNavBarBar.view])
        let heightConstraint = NSLayoutConstraint(item: underNavBarBar.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: underNavBarBarHeight)
        
        topBarContainer.addConstraints(horisontalConstraints + verticalConstraints + [heightConstraint])
        
        floatingHeaderContainerHeightConstraint.constant = underNavBarBarHeight
        calculatedUnderNavBarBarHeight = underNavBarBarHeight
    }
    
    func showUploadFolder(with action: TabBarViewController.Action) {
        self.customTabBarController?.handleAction(action)
    }
    
    func createFile(fileName: String, documentType: String) {
        output.onlyOfficeCreateFile(fileName: fileName, documentType: documentType)
    }
}

// MARK: - ScrollViewIndicator

extension BaseFilesGreedViewController {
    
    func changeScrollIndicatorTitle(with text: String) {
        scrollIndicator?.sectionTitle = text
    }
    
    func startScrollCollectionView() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideScrollIndicator), object: nil)
        let hidden = collectionView.contentOffset.y < contentSliderH?.constant ?? 0
        scrollIndicator?.changeHiddenState(to: hidden)
    }
    
    func endScrollCollectionView() {
        perform(#selector(hideScrollIndicator), with: nil, afterDelay: NumericConstants.scrollIndicatorAnimationDuration)
    }
    
    @objc private func hideScrollIndicator() {
        scrollIndicator?.changeHiddenState(to: true)
    }
    
    private func scrollIndicator(set topOffset: CGFloat) {
        scrollIndicator?.titleOffset = topOffset
    }
}

// MARK: - PrivateShareSliderFilesCollectionManagerDelegate
extension BaseFilesGreedViewController: PrivateShareSliderFilesCollectionManagerDelegate {
    func showAll() {
        output.openPrivateShareFiles()
    }
    
    func open(entity: WrapData, allEnteties: [WrapData]) {
        output.openPrivateSharedItem(entity: entity, sharedEnteties: allEnteties)
    }
    
    func startAsyncOperation() {
        showSpinner()
    }
    
    func completeAsyncOperation() {
        hideSpinner()
    }
}

// MARK: - GridListTopBarDelegate
extension BaseFilesGreedViewController: GridListTopBarDelegate {
    func onMoreButton() {
        output.moreActionsPressed(sender: self)
    }
    
    func filterChanged(filter: MoreActionsConfig.MoreActionsFileType) {
        output.filtersTopBar(cahngedTo: [filter])
    }
    
    func sortingRuleChanged(rule: MoreActionsConfig.SortRullesType) {
        output.sortedPushedTopBar(with: rule)
    }
    
    func representationChanged(viewType: MoreActionsConfig.ViewType) {
        let asGrid = viewType == .Grid ? true : false
        output.viewAppearanceChangedTopBar(asGrid: asGrid)
    }
}

// MARK: - GridListTopBarDelegate
extension BaseFilesGreedViewController: GridListCountViewDelegate {
    func cancelSelection() {
        output.onCancelSelection()
        configureCountView(isShown: false)
    }
}
