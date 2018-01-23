//
//  BaseFilesGreedViewController.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BaseFilesGreedViewController: BaseViewController, BaseFilesGreedViewInput, GridListTopBarDelegate, ViewForPopUpDelegate {

    var output: BaseFilesGreedViewOutput!
    
    var navBarConfigurator = NavigationBarConfigurator()

    var refresher:UIRefreshControl!
    
    let floatingView = FloatingView()
        
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
    
    @IBOutlet weak var startCreatingFilesButton: BlueButtonWithWhiteText!
    
    @IBOutlet weak var topBarContainer: UIView!
    
    @IBOutlet weak var noFilesTopLabel: UILabel?
    
    var scrolliblePopUpView = ViewForPopUp()
    
    @IBOutlet weak var floatingHeaderContainerHeightConstraint: NSLayoutConstraint!
    
    var contentSlider: LBAlbumLikePreviewSliderViewController?
    weak var contentSliderTopY: NSLayoutConstraint? = nil
    weak var contentSliderH: NSLayoutConstraint? = nil
    
    var underNavBarBar: GridListTopBar?
    
    let conf = NavigationBarConfigurator()
    var refresherY: CGFloat = 0
    
    let underNavBarBarHeight: CGFloat = 53
    
    @IBOutlet private weak var topCarouselConstraint: NSLayoutConstraint!
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        collectionView!.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        refresher.tintColor = ColorConstants.whiteColor
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView!.addSubview(refresher)
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        cancelButton.addTarget(self, action: #selector(onCancelSelectionButton), for: .touchUpInside)
        cancelButton.setTitle(TextConstants.cancelSelectionButtonTitle, for: .normal)
        cancelButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 19)
        
        cancelSelectionButton = UIBarButtonItem(customView: cancelButton)
        
        let cancelBackButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        cancelBackButton.addTarget(self, action: #selector(onBackButton), for: .touchUpInside)
        cancelBackButton.setTitle(TextConstants.cancelSelectionButtonTitle, for: .normal)
        cancelBackButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelBackButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 19)
        
        backAsCancelBarButton = UIBarButtonItem(customView: cancelBackButton)
        
        noFilesLabel.text = TextConstants.photosVideosViewNoPhotoTitleText
        noFilesLabel.textColor = ColorConstants.textGrayColor
        noFilesLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        
        noFilesTopLabel?.text = TextConstants.folderEmptyText
        noFilesTopLabel?.textColor = ColorConstants.grayTabBarButtonsColor
        noFilesTopLabel?.font = UIFont.TurkcellSaturaRegFont(size: 19)
        
        startCreatingFilesButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 22)
        startCreatingFilesButton.setTitle(TextConstants.photosVideosViewNoPhotoButtonText , for: .normal)
        
        output.viewIsReady(collectionView: collectionView)
        
        //carouselContainer.setHConstraint(hConstraint: floatingHeaderContainerHeightConstraint)
        
//        if #available(iOS 11.0, *) {
//            topCarouselConstraint.constant = underNavBarBarHeight//0
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        editingTabBar?.view.layoutIfNeeded()
        
        if mainTitle != "" {
            subTitle = output.getSortTypeString()
        }
//        if let unwrapedSlider = contentSlider { //FIXME: shiwt reload mechanic to presenter, so modules would speak as normal
//            unwrapedSlider.reloadAllData()
//        }
        output.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configurateNavigationBar()
        configurateViewForPopUp()
    }
    
    func configurateViewForPopUp(){
        CardsManager.default.addViewForNotification(view: scrolliblePopUpView)
    }
    
    func configurateNavigationBar() {
        homePageNavigationBarStyle()
        configureNavBarActions()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        floatingView.hideView(animated: true)
        output.viewWillDisappear()
    }
    
    deinit{
         CardsManager.default.removeViewForNotification(view: scrolliblePopUpView)
         NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - SearchBarButtonPressed
    
   func configureNavBarActions(isSelecting: Bool = false) {
        let search = NavBarWithAction(navItem: NavigationBarList().search, action: { (_) in
            let router = RouterVC()
            let searchViewController = router.searchView()
            router.pushViewControllerWithoutAnimation(viewController: searchViewController)
        })
        let more = NavBarWithAction(navItem: NavigationBarList().more, action: { [weak self] _ in
            self?.output.moreActionsPressed(sender: NavigationBarList().more)
        })
        let rightActions: [NavBarWithAction] = isSelecting ? [more] : [more, search]
        navBarConfigurator.configure(right: rightActions, left: [])
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }
    
    func configurateDeleteNavBarActions(deleteAction: @escaping () -> Swift.Void) {
        let delete = NavBarWithAction(navItem: NavigationBarList().delete, action: { (_) in
            deleteAction()
        })
        navBarConfigurator.configure(right: [delete], left: [])
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }
    
    func configurateFreeAppSpaceActions(deleteAction: @escaping () -> Swift.Void) {
        let delete = NavBarWithAction(navItem: NavigationBarList().delete, action: { (_) in
            deleteAction()
        })

        navBarConfigurator.configure(right: [delete], left: [])
        
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
        navigationItem.leftBarButtonItem = backAsCancelBarButton
    }
    
    @IBAction func onStartCreatingFilesButton(){
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
    
    func getCollectionViewWidth() -> CGFloat{
        return collectionView.frame.size.width
    }
    
    @objc func loadData() {
        output.onReloadData()
        contentSlider?.reloadAllData()
    }
    
    func stopRefresher() {
        DispatchQueue.main.async {
            self.refresher.endRefreshing()
        }
    }
    
    func showCustomPopUpWithInformationAboutAccessToMediaLibrary(){
        UIApplication.showErrorAlert(message: TextConstants.photosVideosViewHaveNoPermissionsAllertText)
    }
    
    func setCollectionViewVisibilityStatus(visibilityStatus: Bool){
        collectionView.isHidden = visibilityStatus
    }
    
    func startSelection(with numberOfItems: Int) {
        navigationItem.leftBarButtonItem = cancelSelectionButton!
        selectedItemsCountChange(with: numberOfItems)
        navigationBarWithGradientStyle()
        configureNavBarActions(isSelecting: true)
        underNavBarBar?.setSorting(enabled: false)
    }
    
    func stopSelection() {
        self.navigationItem.leftBarButtonItem = nil
        homePageNavigationBarStyle()
        configureNavBarActions(isSelecting: false)
        underNavBarBar?.setSorting(enabled: true)
    }
    
    func setThreeDotsMenu(active isActive: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isActive
    }
    
    func showNoFilesWith(text: String, image: UIImage, createFilesButtonText: String) {
        noFilesLabel.text = text
        noFilesImage.image = image
        startCreatingFilesButton.setTitle(createFilesButtonText, for: .normal)
        noFilesView.isHidden = false
        topBarContainer.isHidden = false
    }
    
    func showNoFilesTop() {
        noFilesTopLabel?.isHidden = false
        topBarContainer.isHidden = true
    }
    
    func hideNoFiles() {
        noFilesView.isHidden = true
        noFilesTopLabel?.isHidden = true
        topBarContainer.isHidden = false
    }
    
    @objc func onCancelSelectionButton(){
        output.onCancelSelection()
    }
    
    @objc func onBackButton(){
        RouterVC().popViewController()
    }
    
    func changeSortingRepresentation(sortType type: SortedRules) {
        if self.mainTitle != "" {
            self.setTitle(withString: self.mainTitle, andSubTitle: type.descriptionForTitle)
        }
    }
    
    func getRemoteItemsService() -> RemoteItemsService{
        return output.getRemoteItemsService()
    }
    
    func getFolder() -> Item?{
        return output.getFolder()
    }
    
    func selectedItemsCountChange(with count: Int) {
        setTitle(withString: String(count) + " Selected")
    }
    
    static let sliderH : CGFloat = 180
    
    private func setupSlider(sliderController: LBAlbumLikePreviewSliderViewController) {
        contentSlider = sliderController
        
        let hTopPopUpView = scrolliblePopUpView.frame.size.height
        
        let subView = UIView(frame: CGRect(x: 0, y: -BaseFilesGreedViewController.sliderH - hTopPopUpView, width: collectionView.frame.size.width, height: BaseFilesGreedViewController.sliderH))
        subView.addSubview(sliderController.view)
        
        if let yConstr = self.contentSliderTopY {
            yConstr.constant = -hTopPopUpView - BaseFilesGreedViewController.sliderH
        }
        collectionView.updateConstraints()
        
        collectionView.clipsToBounds = false
        collectionView.contentInset = UIEdgeInsets(top: BaseFilesGreedViewController.sliderH + hTopPopUpView, left: 0, bottom: 25, right: 0)
        collectionView.addSubview(subView)
        sliderController.view.frame = subView.bounds
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraintsArray = [NSLayoutConstraint]()
        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .top, relatedBy: .equal, toItem: scrolliblePopUpView, attribute: .bottom, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .centerX, relatedBy: .equal, toItem: collectionView, attribute: .centerX, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .width, relatedBy: .equal, toItem: collectionView, attribute: .width, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: subView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: BaseFilesGreedViewController.sliderH))
        
        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .left, relatedBy: .equal, toItem: subView, attribute: .left, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .top, relatedBy: .equal, toItem: subView, attribute: .top, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .right, relatedBy: .equal, toItem: subView, attribute: .right, multiplier: 1, constant: 0))
        constraintsArray.append(NSLayoutConstraint(item: sliderController.view, attribute: .bottom, relatedBy: .equal, toItem: subView, attribute: .bottom, multiplier: 1, constant: 0))
        
        NSLayoutConstraint.activate(constraintsArray)
    
        refresherY =  -hTopPopUpView - BaseFilesGreedViewController.sliderH + 30
        updateRefresher()
        
        noFilesViewCenterOffsetConstraint.constant = BaseFilesGreedViewController.sliderH/2
    }
    
    private func setupViewForPopUp(){
        collectionView.clipsToBounds = false
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
        scrolliblePopUpView.delegate = self
    }
    
    //MARK: ViewForPopUpDelegate
    
    func onUpdateViewForPopUpH(h: CGFloat){
        var sliderH: CGFloat = 0
        if let slider = self.contentSlider {
            sliderH = sliderH + slider.view.frame.size.height
        }
        
        let calculatedH = h + sliderH
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            
            if let yConstr = self.contentSliderTopY {
                yConstr.constant = -h - sliderH
            }
            if let hConstr = self.contentSliderH {
                hConstr.constant = h
            }
            
            self.view.layoutIfNeeded()
            self.collectionView.contentInset = UIEdgeInsets(top: h + sliderH, left: 0, bottom: 25, right: 0)
            let point = CGPoint(x: 0, y: -h - sliderH)
            self.collectionView.setContentOffset(point, animated: true)
            
            
        }
        
        refresherY = -calculatedH + 30
        updateRefresher()
    }
    
    func updateRefresher(){
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
    }
    
    
    //MARK: - TopBar/UnderNavBarBar
    
    func filterChanged(filter: MoreActionsConfig.MoreActionsFileType) {
         output.filtersTopBar(cahngedTo: [filter])
    }
    
    func sortingRuleChanged(rule: MoreActionsConfig.SortRullesType) {
        output.sortedPushedTopBar(with: rule)
    }
    
    func representationChanged(viewType: MoreActionsConfig.ViewType) {
        var asGrid: Bool
        viewType == .Grid ? (asGrid = true) : (asGrid = false)
        output.viewAppearanceChangedTopBar(asGrid: asGrid)
    }
}

