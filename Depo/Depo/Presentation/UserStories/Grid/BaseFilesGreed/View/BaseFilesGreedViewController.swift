//
//  BaseFilesGreedViewController.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BaseFilesGreedViewController: BaseViewController, BaseFilesGreedViewInput, GridListTopBarDelegate, CardsContainerViewDelegate {

    var output: BaseFilesGreedViewOutput!
    
    var navBarConfigurator = NavigationBarConfigurator()

    var refresher: UIRefreshControl!
        
    var cancelSelectionButton: UIBarButtonItem?
    
    var backAsCancelBarButton: UIBarButtonItem?
    
    var editingTabBar: BottomSelectionTabBarViewController?
    
    var isFavorites: Bool = false
    
    var mainTitle: String = ""
    
    var subTitle: String = ""
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var noFilesView: UIView!
    
    @IBOutlet weak var noFilesLabel: UILabel!
    
    @IBOutlet weak var noFilesImage: UIImageView!
    
    @IBOutlet weak var noFilesViewCenterOffsetConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startCreatingFilesButton: BlueButtonWithNoFilesWhiteText!
    
    @IBOutlet weak var topBarContainer: UIView!
    
    @IBOutlet weak var noFilesTopLabel: UILabel?
    
    var scrollablePopUpView = CardsContainerView()
    
    @IBOutlet weak var floatingHeaderContainerHeightConstraint: NSLayoutConstraint!
    
    var contentSlider: LBAlbumLikePreviewSliderViewController?
    weak var contentSliderTopY: NSLayoutConstraint?
    weak var contentSliderH: NSLayoutConstraint?
    
    var underNavBarBar: GridListTopBar?
    
    let conf = NavigationBarConfigurator()
    var refresherY: CGFloat = 0
    
    let underNavBarBarHeight: CGFloat = 53
    var calculatedUnderNavBarBarHeight: CGFloat = 0
    
    @IBOutlet private weak var topCarouselConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var scrollIndicator: CustomScrollIndicator?
    
    var showOnlySyncItemsCheckBox: CheckBoxView?
    private let showOnlySyncItemsCheckBoxHeight: CGFloat = 44
    
    private var isRefreshAllowed = true
    
    var status: ItemStatus = .active
    
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
        
        noFilesLabel.text = TextConstants.photosVideosViewNoPhotoTitleText
        noFilesLabel.textColor = ColorConstants.textGrayColor
        noFilesLabel.font = UIFont.TurkcellSaturaRegFont(size: 14)
        
        noFilesTopLabel?.text = TextConstants.folderEmptyText
        noFilesTopLabel?.textColor = ColorConstants.grayTabBarButtonsColor
        noFilesTopLabel?.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        startCreatingFilesButton.setTitle(TextConstants.photosVideosViewNoPhotoButtonText, for: .normal)
        
        scrollIndicator?.changeHiddenState(to: true, animated: false)
        
        output.viewIsReady(collectionView: collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        editingTabBar?.view.layoutIfNeeded()
        
        if mainTitle != "" {
            subTitle = output.getSortTypeString()
        }
        
        output.viewWillAppear()
    
        if let searchController = navigationController?.topViewController as? SearchViewController {
            searchController.dismissController(animated: false)
        }
        scrollablePopUpView.isActive = true
        CardsManager.default.updateAllProgressesInCardsForView(view: scrollablePopUpView)
        output.needToReloadVisibleCells()
        configurateNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configurateViewForPopUp()
        output.updateThreeDotsButton()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scrollablePopUpView.isActive = false
        super.viewDidDisappear(animated)
    }
    
    func configurateViewForPopUp() {
        CardsManager.default.addViewForNotification(view: scrollablePopUpView)
    }
    
    func configurateNavigationBar() {
        homePageNavigationBarStyle()
        configureNavBarActions()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        output.viewWillDisappear()
    }
    
    deinit {
         CardsManager.default.removeViewForNotification(view: scrollablePopUpView)
         NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - SearchBarButtonPressed
    
   func configureNavBarActions(isSelecting: Bool = false) {
        let search = NavBarWithAction(navItem: NavigationBarList().search, action: { [weak self] _ in
            self?.output.searchPressed(output: self)
        })
        let more = NavBarWithAction(navItem: NavigationBarList().more, action: { [weak self] _ in
            self?.output.moreActionsPressed(sender: NavigationBarList().more)
        })
        let rightActions: [NavBarWithAction] = isSelecting ? [more] : [more, search]
        navBarConfigurator.configure(right: rightActions, left: [])
    
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

    
    @IBAction func onStartCreatingFilesButton() {
        output.onStartCreatingPhotoAndVideos()
    }
    
    // MARK: PhotosAndVideosViewInput
    
    func setupInitialState() {
        setupViewForPopUp()
        if let checkBox = showOnlySyncItemsCheckBox {
            setup(checkBox: checkBox)
        }
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
        navigationBarWithGradientStyle()
        configureNavBarActions(isSelecting: true)
        underNavBarBar?.setSorting(enabled: false)
    }
    
    func stopSelection() {
        let navigationItem = (parent as? SegmentedController)?.navigationItem ?? self.navigationItem
        navigationItem.leftBarButtonItem = nil
        
        homePageNavigationBarStyle()
        configureNavBarActions(isSelecting: false)
        underNavBarBar?.setSorting(enabled: true)
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
        if service is DocumentService || service is MusicService {
            startCreatingFilesButton.isHidden = true
        }
    }
    
    func showNoFilesTop(text: String) {
        noFilesTopLabel?.text = text
        noFilesTopLabel?.isHidden = !scrollablePopUpView.viewsArray.isEmpty
        topBarContainer.isHidden = true
        floatingHeaderContainerHeightConstraint.constant = 0
        view.layoutIfNeeded()
    }
    
    func hideNoFiles() {
        noFilesView.isHidden = true
        noFilesTopLabel?.isHidden = true
        topBarContainer.isHidden = false
        floatingHeaderContainerHeightConstraint.constant = calculatedUnderNavBarBarHeight
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
    }
    
    static let sliderH: CGFloat = 139
    
    private func setupSlider(sliderController: LBAlbumLikePreviewSliderViewController) {
        contentSlider = sliderController

        var height = scrollablePopUpView.frame.size.height + BaseFilesGreedViewController.sliderH
        if showOnlySyncItemsCheckBox != nil {
            height += showOnlySyncItemsCheckBoxHeight
        }
        
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
        
        let relatedView = showOnlySyncItemsCheckBox ?? scrollablePopUpView
        
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
        
        noFilesViewCenterOffsetConstraint.constant = BaseFilesGreedViewController.sliderH / 2
    }
    
    private func setupViewForPopUp() {
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        collectionView.addSubview(scrollablePopUpView)
        
        scrollablePopUpView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraintsArray = [NSLayoutConstraint]()
        contentSliderTopY = NSLayoutConstraint(item: scrollablePopUpView, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: 0)
        constraintsArray.append(contentSliderTopY!)
        constraintsArray.append(NSLayoutConstraint(item: scrollablePopUpView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: scrollablePopUpView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        contentSliderH = NSLayoutConstraint(item: scrollablePopUpView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        constraintsArray.append(contentSliderH!)
        
        NSLayoutConstraint.activate(constraintsArray)
        scrollablePopUpView.delegate = self
    }
    
    private func setup(checkBox: CheckBoxView) {
        collectionView.addSubview(checkBox)
        
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraintsArray = [NSLayoutConstraint]()
        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .top, relatedBy: .equal, toItem: scrollablePopUpView, attribute: .bottom, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: checkBox, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: showOnlySyncItemsCheckBoxHeight))
        
        NSLayoutConstraint.activate(constraintsArray)
        checkBox.delegate = self
    }
    
    // MARK: ViewForPopUpDelegate
    
    func onUpdateViewForPopUpH(h: CGFloat) {
        let originalPoint = collectionView.contentOffset
        var sliderH: CGFloat = 0
        if let slider = self.contentSlider {
            sliderH = sliderH + slider.view.frame.size.height
        }
        var checkBoxH: CGFloat = 0
        if let checkBox = showOnlySyncItemsCheckBox {
            checkBoxH = checkBox.frame.height
        }
        
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
    
    
    // MARK: - TopBar/UnderNavBarBar
    
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

extension BaseFilesGreedViewController: CheckBoxViewDelegate {
    
    func checkBoxViewDidChangeValue(_ value: Bool) {
        output.showOnlySyncedItems(value)
    }
    
    func openAutoSyncSettings() { }
}
