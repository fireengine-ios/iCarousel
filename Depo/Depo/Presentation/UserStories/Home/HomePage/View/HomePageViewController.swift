//
//  HomePageHomePageViewController.swift
//  Depo
//
//  Created by AlexanderP on 22/06/2017.
//  Copyright © 2017 LifeTech. All rights reserved.
//

enum SegmentType {
    case tools
    case campaigns
}

import UIKit

final class HomePageViewController: BaseViewController {
    
    //MARK: IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let segmentContainerView = UIView()
    private let segmentStackView = UIStackView()
    
    private let stackView1Container = UIView()
    private let stackView2Container = UIView()
    
    private let button1StackView = UIStackView()
    private let button2StackView = UIStackView()
    
    private let button1 = UIButton(type: .system)
    private let button2 = UIButton(type: .system)
    
    private let segmentStackEmptyView = UIView()
    
    //MARK: Properties
    var output: HomePageViewOutput!
    
    var navBarConfigurator = NavigationBarConfigurator()
    
    ///special flag for delaying spotlight present if after appearing new contorller(s) will be presented/pushed
    var isNeedShowSpotlight = true
    
    let homePageDataSource = HomeCollectionViewDataSource()
    
    private var refreshControl = UIRefreshControl()
    private lazy var shareCardContentManager = ShareCardContentManager(delegate: self)
    
    private var homepageIsActiveAndVisible: Bool {
        var result = false
        if let topController = navigationController?.topViewController, topController == self {
            result = true
        }
        return result
    }
    
    private var isGiftButtonEnabled = false
    
    //MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        needToShowTabBar = true
        navigationBarHidden = true
        
        debugLog("HomePage viewDidLoad")
        homePageDataSource.configurateWith(collectionView: collectionView, viewController: self, delegate: self)
        debugLog("HomePage DataSource setuped")
        
        CardsManager.default.addViewForNotification(view: homePageDataSource)
        
        configurateRefreshControl()
        
        showSpinner()
        
        setDefaultNavigationHeaderActions()
        
        setupSegmentControl()
        
        segmentContainerView.isHidden = true
        
        output.viewIsReady()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateNavigationItemsState(state: true)
        
        if let searchController = navigationController?.topViewController as? SearchViewController {
            searchController.dismissController(animated: false)
        }
        
        output.viewWillAppear()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        debugLog("HomePage viewDidAppear")
        
        homePageDataSource.isViewActive = true
        
        CardsManager.default.updateAllProgressesInCardsForView(view: homePageDataSource)
        
        if homepageIsActiveAndVisible {
            configureNavBarActions()
        }
        
        if isNeedShowSpotlight {
            requestShowSpotlight()
        } else {
            isNeedShowSpotlight = true
        }
        
        output.viewIsReadyForPopUps()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        homePageDataSource.isViewActive = false
        
        hideSpotlightIfNeeded()
    }
    
    deinit {
        CardsManager.default.removeViewForNotification(view: homePageDataSource)
    }
    
    // MARK: Segment Control Components
    
    private func setupSegmentControl() {
            segmentContainerView.backgroundColor = ColorConstants.fileGreedCellColorSecondary
            segmentContainerView.layer.cornerRadius = 20
            segmentContainerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(segmentContainerView)
            
            segmentStackView.axis = .horizontal
            segmentStackView.distribution = .fill
            segmentStackView.alignment = .center
            segmentStackView.spacing = 8
            segmentStackView.translatesAutoresizingMaskIntoConstraints = false
            
            button1StackView.axis = .horizontal
            button1StackView.distribution = .fill
            button1StackView.alignment = .center
            button1StackView.spacing = 2
            button1StackView.translatesAutoresizingMaskIntoConstraints = false
            
            button2StackView.axis = .horizontal
            button2StackView.distribution = .fill
            button2StackView.alignment = .center
            button2StackView.spacing = 2
            button2StackView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView1Container.layer.cornerRadius = 12
            stackView1Container.backgroundColor = AppColor.settingsMyPackages.color
            stackView1Container.translatesAutoresizingMaskIntoConstraints = false
            
            stackView2Container.layer.cornerRadius = 12
            stackView2Container.backgroundColor = AppColor.settingsMyPackages.color
            stackView2Container.translatesAutoresizingMaskIntoConstraints = false
            
            segmentStackEmptyView.backgroundColor = .clear
            segmentStackEmptyView.translatesAutoresizingMaskIntoConstraints = false
            
            button1.setTitle(localized(.discoverTools), for: .normal)
            button1.setTitleColor(AppColor.label.color, for: .normal)
            button1.titleLabel?.font = .appFont(.medium, size: 14)
            button1.addTarget(self, action: #selector(segmentButtonTapped(_:)), for: .touchUpInside)
            
            button2.setTitle(localized(.discoverCampaigns), for: .normal)
            button2.setTitleColor(AppColor.label.color, for: .normal)
            button2.titleLabel?.font = .appFont(.medium, size: 14)

            button2.addTarget(self, action: #selector(segmentButtonTapped(_:)), for: .touchUpInside)
            
            segmentContainerView.addSubview(segmentStackView)
            
            button1StackView.addArrangedSubview(button1)

            button2StackView.addArrangedSubview(button2)

            stackView1Container.addSubview(button1StackView)
            stackView2Container.addSubview(button2StackView)
            
            segmentStackView.addArrangedSubview(stackView1Container)
            segmentStackView.addArrangedSubview(stackView2Container)
            segmentStackView.addArrangedSubview(segmentStackEmptyView)
        
            NSLayoutConstraint.activate([
                segmentContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
                segmentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                segmentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                segmentContainerView.heightAnchor.constraint(equalToConstant: 42),
                
                segmentStackView.topAnchor.constraint(equalTo: segmentContainerView.topAnchor, constant: 8),
                segmentStackView.leadingAnchor.constraint(equalTo: segmentContainerView.leadingAnchor, constant: 8),
                segmentStackView.trailingAnchor.constraint(equalTo: segmentContainerView.trailingAnchor, constant: -8),
                segmentStackView.bottomAnchor.constraint(equalTo: segmentContainerView.bottomAnchor, constant: -8),
                
                button1StackView.topAnchor.constraint(equalTo: stackView1Container.topAnchor, constant: 8),
                button1StackView.leadingAnchor.constraint(equalTo: stackView1Container.leadingAnchor, constant: 8),
                button1StackView.trailingAnchor.constraint(equalTo: stackView1Container.trailingAnchor, constant: -8),
                button1StackView.bottomAnchor.constraint(equalTo: stackView1Container.bottomAnchor, constant: -8),
                
                button2StackView.topAnchor.constraint(equalTo: stackView2Container.topAnchor, constant: 8),
                button2StackView.leadingAnchor.constraint(equalTo: stackView2Container.leadingAnchor, constant: 8),
                button2StackView.trailingAnchor.constraint(equalTo: stackView2Container.trailingAnchor, constant: -8),
                button2StackView.bottomAnchor.constraint(equalTo: stackView2Container.bottomAnchor, constant: -8),
            ])
            
            collectionView.contentInset = UIEdgeInsets(top: segmentContainerView.frame.height + 58, left: 0, bottom: 0, right: 0)
            
            updateSelectedSegment(index: 0)
        }
    
    @objc private func segmentButtonTapped(_ sender: UIButton) {
        if sender == button1 {
            updateSelectedSegment(index: 0)
            output.updateCollectionView(for: .tools)
        } else if sender == button2 {
            updateSelectedSegment(index: 1)
            output.updateCollectionView(for: .campaigns)
        }
    }
    
    private func updateSelectedSegment(index: Int) {
        switch index {
        case 0:
            stackView2Container.backgroundColor = .clear
            stackView1Container.backgroundColor = AppColor.settingsMyPackages.color
        case 1:
            stackView1Container.backgroundColor = .clear
            stackView2Container.backgroundColor = AppColor.settingsMyPackages.color
        default:
            break
        }
    }
    
    func showSegmentControl() {
        segmentContainerView.isHidden = false
    }

    func hideSegmentControl() {
        segmentContainerView.isHidden = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func updateNavigationItemsState(state: Bool) {
        guard let items = navigationItem.rightBarButtonItems else {
            return
        }
        
        for item in items {
            item.isEnabled = state
        }
    }
    
    //MARK: Search
    func configureNavBarActions() {
        let search = NavBarWithAction(navItem: NavigationBarList().search, action: { [weak self] _ in
            self?.updateNavigationItemsState(state: false)
            self?.output.showSearch(output: self)
        })
        
        let setting = NavBarWithAction(navItem: NavigationBarList().settings, action: { [weak self] _ in
            self?.updateNavigationItemsState(state: false)
            self?.output.showSettings()
        })
        navBarConfigurator.configure(right: [search, setting], left: [])
        if isGiftButtonEnabled {
            let gift = NavBarWithAction(navItem: NavigationBarList().gift, action: { [weak self] _ in
                self?.output.giftButtonPressed()
            })
            navBarConfigurator.append(rightButton: gift, leftButton: nil)
        }
        
        navigationItem.leftBarButtonItems = navBarConfigurator.leftItems
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
    }
    
    @objc func reloadData() {
        DispatchQueue.main.async {
            self.showSpinner()
            self.refreshControl.endRefreshing()
            self.output.needRefresh()
        }
    }
    
    //MARK: Utility Methods(private)
    private func configurateRefreshControl() {
        refreshControl.tintColor = ColorConstants.whiteColor
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.addSubview(refreshControl)
    }
    
    //in case if we push new controller
    private func hideSpotlightIfNeeded() {
        if let spotlight = presentedViewController as? SpotlightViewController {
            spotlight.dismiss(animated: true, completion: nil)
        }
    }
}

extension HomePageViewController: HeaderContainingViewControllerChild {
    var scrollViewForHeaderTracking: UIScrollView? {
        
        return nil
    }
}

// MARK: - HomeCollectionViewDataSourceDelegate
extension HomePageViewController: HomeCollectionViewDataSourceDelegate {
    //MARK: CardsShareButtonDelegate
    
    func share(item: BaseDataSourceItem, type: CardShareType) {
        shareCardContentManager.presentSharingMenu(item: item, type: type)
    }
    
    //MARK: HomeCollectionViewDataSourceDelegate
    func onCellHasBeenRemovedWith(controller: UIViewController) { }
    
    func numberOfColumns() -> Int {
        return Device.isIpad ? 2 : 1
    }
    
    func didReloadCollectionView(_ collectionView: UICollectionView) {
        requestShowSpotlight()
    }
    
    // MARK: - HomeCollectionViewDataSourceDelegate Private Utility Methods
    
    private func requestShowSpotlight() {
        var cardTypes: [SpotlightType] = [.homePageIcon, .homePageGeneral]
        cardTypes.append(contentsOf: homePageDataSource.cards.compactMap { SpotlightType(cardView: $0) })
        output.requestShowSpotlight(for: cardTypes)
    }
}

//MARK: - HomePageViewInput
extension HomePageViewController: HomePageViewInput {
    
    func showSnackBarWithMessage(message: String) {
        SnackbarManager.shared.show(type: .action, message: message)
    }
    
    func stopRefresh() {
        hideSpinner()
    }
    
    func startSpinner() {
        showSpinner()
    }
    
    func updateCollectionView(with items: [HomeCardResponse]) {
        homePageDataSource.updateData(with: items)
        
        collectionView.reloadData()
    }
    
    //MARK: Spotlight
    func needShowSpotlight(type: SpotlightType) {
        guard let tabBarVC = UIApplication.topController() as? TabBarViewController else {
            return
        }
        
        frameForSpotlight(type: type, controller: tabBarVC) { [weak self] frame in
            guard
                let navVC = tabBarVC.activeNavigationController,
                navVC.topViewController is HomePageViewController,
                frame != .zero
            else {
                return
            }
            
            let controller = SpotlightViewController.with(rect: frame, message: type.title) { [weak self] in
                guard let self = self else {
                    return
                }
                
                self.output.shownSpotlight(type: type)
                self.output.closedSpotlight(type: type)
            }
            
            tabBarVC.present(controller, animated: true)
        }
    }
    
    func showGiftBox() {
        isGiftButtonEnabled = true
        configureNavBarActions()
    }
    
    func hideGiftBox() {
        isGiftButtonEnabled = false
        configureNavBarActions()
    }
    
    func closePermissionPopUp() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - HomePageViewInput Private Utility Methods
    
    private func frameForSpotlight(type: SpotlightType, controller: TabBarViewController, completion: @escaping (_ frame: CGRect) -> ()) {
        var frame: CGRect = .zero
        
        switch type {
        case .homePageIcon:
            let frameBounds = controller.frameForTabAtIndex(index: 0)
            frame = controller.tabBar.convert(frameBounds, to: controller.contentView)
            if !Device.operationSystemVersionLessThen(11) {
                frame.origin.y -= UIApplication.shared.statusBarFrame.height
            }
            completion(frame)
            
        case .homePageGeneral:
            guard let premiumCardFrame = homePageDataSource.cards.first?.frame else {
                assertionFailure("premiumCard should be presented")
                completion(.zero)
                return
            }
            
            let verticalSpace: CGFloat = 20
            let navBarHeight: CGFloat = 44
            
            frame = CGRect(x: 0,
                           y: premiumCardFrame.height + navBarHeight + verticalSpace,
                           width: premiumCardFrame.width,
                           height: collectionView.frame.height - premiumCardFrame.height - verticalSpace)
            
            completion(frame)
            
        case .movieCard, .albumCard, .collageCard, .filterCard, .animationCard:
            cellCoordinates(cellType: type.cellType, to: controller.contentView, completion: completion)
            
        }
    }
    
    // MARK: - HomePageViewInput Private Utility Methods
    
    private func cellCoordinates<T: BaseCardView>(cellType: T.Type, to: UIView, completion: @escaping (_ frame: CGRect) -> ()) {
        for (row, popupView) in homePageDataSource.cards.enumerated() {
            if type(of: popupView) == cellType {
                let indexPath = IndexPath(row: row, section: 0)
                let indexPathsVisibleCells = collectionView.indexPathsForVisibleItems.sorted { first, second -> Bool in
                    return first < second
                }
                
                if indexPathsVisibleCells.contains(indexPath) {
                    if indexPath == indexPathsVisibleCells.first {
                        collectionView.scrollToItem(at: indexPath, at: .top, animated: false)
                    } else {
                        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
                    }
                    
                    var frame = popupView.convert(popupView.bounds, to: to)
                    frame.origin.y = max(0, frame.origin.y)
                    frame.size.height = popupView.spotlightHeight()
                    completion(frame)
                } else {
                    guard let layout = collectionView.collectionViewLayout as? HomeCollectionViewLayout else {
                        completion(.zero)
                        return
                    }
                    
                    CATransaction.flush() //rendering what is already ready
                    
                    let offset = layout.frameFor(indexPath: indexPath).origin.y
                    
                    let isLastCell = indexPath.row == homePageDataSource.cards.count - 1
                    
                    UIView.animate(withDuration: 0.1, animations: {
                        if isLastCell {
                            self.collectionView.scrollToBottom(animated: false)
                        } else {
                            self.collectionView.setContentOffset(CGPoint(x: 0, y: offset - 50), animated: false)
                        }
                    }, completion: { _ in
                        var frame = popupView.convert(popupView.bounds, to: to)
                        frame.origin.y = max(0, frame.origin.y)
                        frame.size.height = popupView.spotlightHeight()
                        completion(frame)
                        
                    })
                }
                return
            }
        }
        
        completion (.zero)
    }
    
}

//MARK: - HomeViewTopViewActions
extension HomePageViewController: HomeViewTopViewActions {
    
    func allFilesButtonGotPressed() {
        output.allFilesPressed()
    }
    
    func createAStoryButtonGotPressed() {
        output.createStory()
    }
    
    func favoritesButtonGotPressed() {
        output.favoritesPressed()
    }
    
    func syncContactsButtonGotPressed() {
        output.onSyncContacts()
    }
}

// MARK: - SearchModuleOutput
extension HomePageViewController: SearchModuleOutput {
    
    func cancelSearch() { }
    
    func previewSearchResultsHide() { }
    
}


extension HomePageViewController: ShareCardContentManagerDelegate {
    func shareOperationStarted() {
        showSpinner()
    }
    
    func shareOperationFinished() {
        hideSpinner()
    }
}
