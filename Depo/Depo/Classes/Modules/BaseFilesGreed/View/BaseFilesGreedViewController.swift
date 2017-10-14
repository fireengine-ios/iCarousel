//
//  BaseFilesGreedViewController.swift
//  Depo
//
//  Created by Oleg on 29/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

import UIKit

class BaseFilesGreedViewController: UIViewController, BaseFilesGreedViewInput, GridListTopBarDelegate, ViewForPopUpDelegate {

    var output: BaseFilesGreedViewOutput!
    
    var navBarConfigurator = NavigationBarConfigurator()

    var refresher:UIRefreshControl!
    
    let floatingView = FloatingView()
        
    var cancelSelectionButton: UIBarButtonItem?
    
    var editingTabBar: BottomSelectionTabBarViewController?
    
    var isFavorites: Bool = false
    
    var mainTitle: String!
    
    var subTitle: String!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var noFilesView: UIView!
    
    @IBOutlet weak var noFilesLabel: UILabel!
    
    @IBOutlet weak var noFilesImage: UIImageView!
    
    @IBOutlet weak var startCreatingFilesButton: BlueButtonWithWhiteText!
    
    @IBOutlet weak var carouselContainer: ViewForPopUp!
    
    var scrolliblePopUpView = ViewForPopUp()
    
    @IBOutlet weak var floatingHeaderContainerHeightConstraint: NSLayoutConstraint!
    
    var contentSlider: LBAlbumLikePreviewSliderViewController?
    weak var contentSliderTopY: NSLayoutConstraint? = nil
    weak var contentSliderH: NSLayoutConstraint? = nil
    
    var underNavBarBar: GridListTopBar?
    
    let conf = NavigationBarConfigurator()
    var refresherY: CGFloat = 0
    
    let underNavBarBarHeight: CGFloat = 53
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresher = UIRefreshControl()
        collectionView!.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        refresher.tintColor = ColorConstants.textGrayColor
        refresher.addTarget(self, action: #selector(loadData), for: .valueChanged)
        collectionView!.addSubview(refresher)
        
        let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
        cancelButton.addTarget(self, action: #selector(onCancelSelectionButton), for: .touchUpInside)
        cancelButton.setTitle(TextConstants.cancelSelectionButtonTitle, for: .normal)
        cancelButton.setTitleColor(ColorConstants.whiteColor, for: .normal)
        cancelButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 19)
        
        cancelSelectionButton = UIBarButtonItem(customView: cancelButton)
        
        noFilesLabel.text = TextConstants.photosVideosViewNoPhotoTitleText
        noFilesLabel.textColor = ColorConstants.textGrayColor
        noFilesLabel.font = UIFont.TurkcellSaturaRegFont(size: 16)
        
        startCreatingFilesButton.titleLabel?.font = UIFont.TurkcellSaturaBolFont(size: 22)
        startCreatingFilesButton.setTitle(TextConstants.photosVideosViewNoPhotoButtonText , for: .normal)
        
        
        output.viewIsReady(collectionView: collectionView)
        let flag = output.needShowNoFileView()
        
        noFilesView.isHidden = !flag
        if (flag){
            noFilesLabel.text = output.textForNoFileLbel()
            startCreatingFilesButton.setTitle(output.textForNoFileButton(), for: .normal)
            noFilesImage.image = output.imageForNoFileImageView()
        }
        
        carouselContainer.setHConstraint(hConstraint: floatingHeaderContainerHeightConstraint)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editingTabBar?.view.layoutIfNeeded()
        
        if mainTitle != "" {
            self.subTitle = output.getSortTypeString()
        }
        output.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        WrapItemOperatonManager.default.addViewForNotification(view: scrolliblePopUpView)
        homePageNavigationBarStyle()
        configureNavBarActions()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        floatingView.hideView(animated: true)
        output.viewWillDisappear()
    }
    
    deinit{
         WrapItemOperatonManager.default.removeViewForNotification(view: scrolliblePopUpView)
    }
    
    
    // MARK: - SearchBarButtonPressed
    
   func configureNavBarActions() {
        let search = NavBarWithAction(navItem: NavigationBarList().search, action: { (_) in
            let router = RouterVC()
            let searchViewController = router.searchView
            searchViewController.modalPresentationStyle = .overCurrentContext
            searchViewController.modalTransitionStyle = .crossDissolve
            router.rootViewController?.present(searchViewController, animated: true, completion: nil)
        })
        let more = NavBarWithAction(navItem: NavigationBarList().more, action: { [weak self] _ in
            self?.output.moreActionsPressed(sender: NavigationBarList().more)
        })
        navBarConfigurator.configure(right: [more, search], left: [])
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
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
        //TODO: refresh slider here Pestryakov
//        contentSlider
    }
    
    func stopRefresher() {
        self.refresher.endRefreshing()
    }
    
    func showCustomPopUpWithInformationAboutAccessToMediaLibrary(){
        CustomPopUp.sharedInstance.showCustomAlert(withText: TextConstants.photosVideosViewHaveNoPermissionsAllertText, okButtonText: TextConstants.ok)
    }
    
    func setCollectionViewVisibilityStatus(visibilityStatus: Bool){
        collectionView.isHidden = visibilityStatus
    }
    
    func setupSelectionStyle(isSelection: Bool){
        if (isSelection){
            self.navigationItem.leftBarButtonItem = cancelSelectionButton!
            setTitle(withString: "1 Selected")
            navigationBarWithGradientStyle()
        }else{
            self.navigationItem.leftBarButtonItem = nil
            homePageNavigationBarStyle()
        }
    }
    
    @objc func onCancelSelectionButton(){
        if (mainTitle != "") && (mainTitle != nil){
            self.setTitle(withString: mainTitle, andSubTitle: subTitle)
        }
        output.onCancelSelection()
    }
    
    func changeSortingRepresentation(sortType type: SortedRules) {
        if self.mainTitle != "" {
            self.setTitle(withString: self.mainTitle, andSubTitle: type.stringValue)
        }
    }
    
    func getRemoteItemsService() -> RemoteItemsService{
        return output.getRemoteItemsService()
    }
    
    func getFolder() -> Item?{
        return output.getFolder()
    }
    
    func selectedItemsCountChange(with count: Int) {
        self.setTitle(withString: String(count) + " Selected")
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
        UIView.animate(withDuration: NumericConstants.durationOfAnimation) {
            
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
        carouselContainer.addSubview(unwrapedTopBar.view)
        
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
        
        carouselContainer.addConstraints(horisontalConstraints + verticalConstraints + [heightConstraint])
        
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

