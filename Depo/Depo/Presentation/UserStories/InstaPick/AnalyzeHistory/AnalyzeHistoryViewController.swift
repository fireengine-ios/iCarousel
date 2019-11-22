//
//  AnalyzeHistoryViewController.swift
//  Depo
//
//  Created by Andrei Novikau on 10/01/2019.
//  Copyright © 2019 LifeTech. All rights reserved.
//

import UIKit

final class AnalyzeHistoryViewController: BaseViewController, NibInit {
    
    @IBOutlet private var designer: AnalyzeHistoryDesigner!
    @IBOutlet private var displayManager: AnalyzeHistoryDisplayManager!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var newAnalysisButton: BlueButtonWithMediumWhiteText!
    @IBOutlet private weak var newAnalysisView: UIView!
    
    private lazy var activityManager = ActivityIndicatorManager()

    private let dataSource = AnalyzeHistoryDataSourceForCollectionView()
    private let instapickService: InstapickService = factory.resolve()
    private let campaignService: CampaignService = CampaignServiceImpl()
    private let instaPickCampaignService = InstaPickCampaignService()

    private let refresher = UIRefreshControl()
    private var page = 0
    private let pageSize = Device.isIpad ? 50 : 30
    private var isLoadingNextPage = false
    
    private var navBarConfigurator = NavigationBarConfigurator()
    private lazy var cancelSelectionButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onCancelSelectionButton))
    }()
    private var navBarRightItems: [UIBarButtonItem]?
    
    private var editingTabBar: BottomSelectionTabBarViewController?
    private var bottomBarPresenter: BottomSelectionTabBarModuleInput?
    private var bottomBarSettablePresenter = AnalyzeHistoryTabBarPresenter()
    private let editingElements: [ElementTypes] = [.delete]
    
    private let instapickRoutingService = InstaPickRoutingService()
    private let router = RouterVC()
    
    // MARK: - Life cycle
    
    deinit {
        instapickService.delegates.remove(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        trackScreen()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadCards()
        
        backButtonForNavigationItem(title: TextConstants.backTitle)
        navigationBarWithGradientStyle()
        editingTabBar?.view.layoutIfNeeded()
    }
    
    func updateAnalyzeCount(with analyzesCount: InstapickAnalyzesCount) {
        self.dataSource.reloadCards(with: analyzesCount)
        self.loadCampaignStatisticsIfNeed(success: nil)
    }
    
    private func trackScreen() {
        let analyticsService: AnalyticsService = factory.resolve()
        analyticsService.logScreen(screen: .photoPickHistory)
        analyticsService.trackDimentionsEveryClickGA(screen: .photoPickHistory)
    }
    
    private func configure() {
        instapickService.delegates.add(self)
        
        activityManager.delegate = self
        displayManager.applyConfiguration(.initial)

        dataSource.setupCollectionView(collectionView: collectionView)
        dataSource.delegate = self
        collectionView.contentInset.bottom = newAnalysisView.bounds.height
        collectionView.backgroundColor = .clear
        
        refresher.tintColor = .clear
        refresher.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.addSubview(refresher)
        
        configureNavBarActions()
        configureBottomTabBar()
        setTitle(withString: TextConstants.analyzeHistoryTitle)
    }
    
    private func configureNavBarActions() {
        let more = NavBarWithAction(navItem: NavigationBarList().more) { [weak self] item in
            self?.onMorePressed(item)
        }
        let rightActions: [NavBarWithAction] = [more]
        navBarConfigurator.configure(right: rightActions, left: [])
        navBarRightItems = navBarConfigurator.rightItems
    }
    
    private func configureBottomTabBar() {
        let bottomBarConfig = EditingBarConfig(elementsConfig: editingElements, style: .default, tintColor: nil)
        let bottomBarVCmodule = BottomSelectionTabBarModuleInitializer()
        let botvarBarVC = bottomBarVCmodule.setupModule(config: bottomBarConfig, settablePresenter: bottomBarSettablePresenter)
        editingTabBar = botvarBarVC
        bottomBarPresenter = bottomBarVCmodule.presenter
        bottomBarSettablePresenter.setup(with: editingElements, delegate: self)
    }
    
    private func startSelection(with count: Int) {
        selectedItemsCountChange(with: count)
        displayManager.applyConfiguration(.selection)
        updateNavBarItems()
    }
    
    private func stopSelection() {
        setTitle(withString: TextConstants.analyzeHistoryTitle)
        dataSource.cancelSelection()
        bottomBarPresenter?.dismiss(animated: true)
        displayManager.applyConfiguration(dataSource.isEmpty ? .empty : .initial)
        updateNavBarItems()
    }
    
    private func selectedItemsCountChange(with count: Int) {
        navigationItem.title = "\(count) \(TextConstants.accessibilitySelected)"
        
        if count == 0 {
            bottomBarPresenter?.dismiss(animated: true)
        } else {
            bottomBarPresenter?.show(animated: true, onView: view)
        }
    }
    
    private func updateNavBarItems() {
        switch displayManager.configuration {
        case .initial:
            navigationItem.rightBarButtonItems = navBarRightItems
            navigationItem.leftBarButtonItem = nil
        case .empty:
            navigationItem.rightBarButtonItems = nil
            navigationItem.leftBarButtonItem = nil
        case .selection:
            navigationItem.rightBarButtonItems = nil
            navigationItem.leftBarButtonItem = cancelSelectionButton
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func newAnalysisAction(_ sender: Any) {
        if let count = dataSource.analysisCount?.left, count > 0 {
            startActivityIndicator()
            instapickRoutingService.getViewController(success: { [weak self] controller in
                self?.stopActivityIndicator()

                if controller is InstapickPopUpController, let vc = self?.router.createRootNavigationControllerWithModalStyle(controller: controller) {
                    self?.router.presentViewController(controller: vc)
                } else if let vc = self?.router.createRootNavigationController(controller: controller) {
                    self?.router.presentViewController(controller: vc)
                } else {
                    assertionFailure("Unexpected controller")
                }
            }, error: { [weak self] errorResponse in
                self?.showError(message: errorResponse.description)
            })
        } else {
            let popup = PopUpController.with(title: TextConstants.analyzeHistoryPopupTitle,
                                         message: TextConstants.analyzeHistoryPopupMessage,
                                         image: .custom(UIImage(named: "popup_info")),
                                         firstButtonTitle: TextConstants.cancel,
                                         secondButtonTitle: TextConstants.analyzeHistorySeeDetails,
                                         secondAction: { [weak self] controller in
                                            controller.close {
                                                self?.onPurchase()
                                            }
                                         })
            
            present(popup, animated: true)
        }
    }
    
    @IBAction private func onCancelSelectionButton(_ sender: Any) {
        stopSelection()
    }
    
    @IBAction private func deleteSelectedItems(_ sender: Any?) {
        deleteAction()
    }
    
    private func onMorePressed(_ sender: Any) {
        if !dataSource.isSelectionStateActive {
            showAlertSheet(with: [.select], sender: sender)
        }
    }
    
    private func showAlertSheet(with types: [ElementTypes], sender: Any?) {
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        types.forEach { type in
            var action: UIAlertAction?
            switch type {
            case .select:
                action = UIAlertAction(title: TextConstants.actionSheetSelect, style: .default, handler: { _ in
                    self.dataSource.startSelection()
                    self.startSelection(with: 0)
                })
            default:
                action = nil
            }
            
            if let action = action {
                actionSheetVC.addAction(action)
            }
        }
        
        let cancelAction = UIAlertAction(title: TextConstants.actionSheetCancel, style: .cancel)
        actionSheetVC.addAction(cancelAction)
        
        actionSheetVC.view.tintColor = UIColor.black
        actionSheetVC.popoverPresentationController?.sourceView = view
        
        if let pressedBarButton = sender as? UIButton {
            var sourceRectFrame = pressedBarButton.convert(pressedBarButton.frame, to: view)
            if sourceRectFrame.origin.x > view.bounds.width {
                sourceRectFrame = CGRect(origin: CGPoint(x: pressedBarButton.frame.origin.x, y: pressedBarButton.frame.origin.y + 20), size: pressedBarButton.frame.size)
            }
            actionSheetVC.popoverPresentationController?.sourceRect = sourceRectFrame
        } else if let item = sender as? UIBarButtonItem {
            actionSheetVC.popoverPresentationController?.barButtonItem = item
            actionSheetVC.popoverPresentationController?.permittedArrowDirections = .up
        }
        present(actionSheetVC, animated: true)
    }
    
    // MARK: - Functions
    
    @objc private func reloadData() {
        stopRefresher()
        guard !dataSource.isSelectionStateActive else {
            return
        }
        
        startActivityIndicator()
        
        reloadCards { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.page = 0
            self.dataSource.isPaginationDidEnd = false
            self.loadNextHistoryPage(completion: { [weak self] _ in
                self?.stopActivityIndicator()
            })

        }
    }
    
    private func stopRefresher() {
        if refresher.isRefreshing {
            DispatchQueue.main.async {
                self.refresher.endRefreshing()
            }
        }
    }
    
    private func reloadCards(success: VoidHandler? = nil) {
        getAnalyzesCount(success: { [weak self] analyzesCount in
            guard let `self` = self else {
                return
            }

            self.dataSource.reloadCards(with: analyzesCount)
            self.loadCampaignStatisticsIfNeed(success: success)
        })
    }
    
    private func loadCampaignStatisticsIfNeed(success: VoidHandler?) {
        
        campaignService.getPhotopickDetails { [weak self] result in
            guard let self = self else {
                success?()
                return
            }
            
            switch result {
            case .success(let campaignCard):
                let isDateAvailable = (campaignCard.startDate...campaignCard.endDate).contains(Date())
                
                if SingletonStorage.shared.isUserFromTurkey, isDateAvailable {
                    self.dataSource.showCampaignCard(with: campaignCard)
                }
                
            case .failure(let errorResult):
                switch errorResult {
                case .empty:
                    break
                case .error(let error):
                    UIApplication.showErrorAlert(message: error.description)
                }
            }
            
            success?()
        }
    }
    
    private func loadNextHistoryPage(completion: BoolHandler? = nil) {
        if isLoadingNextPage || dataSource.isPaginationDidEnd {
            return
        }
        
        isLoadingNextPage = true
        
        instapickService.getAnalyzeHistory(offset: page, limit: pageSize) { [weak self] result in
            guard let `self` = self else {
                return
            }
            
            self.isLoadingNextPage = false
            
            switch result {
            case .success(let history):
                DispatchQueue.main.async {
                    self.page += 1
                    
                    if self.page == 1 {
                        self.dataSource.reloadHistoryItems(history)
                    } else {
                        self.dataSource.appendHistoryItems(history)
                    }
                
                    if self.dataSource.isEmpty {
                        self.displayManager.applyConfiguration(.empty)
                        self.dataSource.showEmptyCard()
                    } else if self.displayManager.configuration == .empty {
                        self.displayManager.applyConfiguration(.initial)
                    }
                    self.updateNavBarItems()
                    completion?(true)
                }
            case .failed(let error):
                completion?(false)
                self.showError(message: error.description)
            }
        }
    }

    private func deleteAction() {
        showDeletePopUp { [weak self] in
            self?.deleteSelectedAnalyzes()
        }
    }

    private func showDeletePopUp(okHandler: @escaping VoidHandler) {
        let controller = PopUpController.with(title: TextConstants.analyzeHistoryConfirmDeleteTitle,
                                              message: TextConstants.analyzeHistoryConfirmDeleteText,
                                              image: .delete,
                                              firstButtonTitle: TextConstants.analyzeHistoryConfirmDeleteNo,
                                              secondButtonTitle: TextConstants.analyzeHistoryConfirmDeleteYes,
                                              secondAction: { vc in
                                                vc.close(completion: okHandler)
        })
        router.presentViewController(controller: controller)
    }
    
    private func deleteSelectedAnalyzes() {
        startActivityIndicator()
        let ids = dataSource.selectedItems.map { $0.requestIdentifier }
        instapickService.removeAnalyzes(ids: ids) { [weak self] result in
            guard let `self` = self else {
                return
            }
            
            switch result {
            case .success:
                self.stopActivityIndicator()
                DispatchQueue.main.async {
                    self.dataSource.deleteSelectedItems(completion: {
                        self.stopSelection()
                        UIApplication.showSuccessAlert(message: TextConstants.popUpDeleteComplete)
                    })
                }
            case .failed(let error):
                self.showError(message: error.description)
            }
        }
    }
    
    private func getAnalyzeDetails(for id: String, analyzesCount: InstapickAnalyzesCount) {
        instapickService.getAnalyzeDetails(id: id) { [weak self] result in
            guard let `self` = self else {
                return
            }

            switch result {
            case .success(let response):
                self.openDetail(for: response, analyzesCount: analyzesCount)
            case .failed(let error):
                self.showError(message: error.description)
            }
        }
    }
    
    private func getAnalyzesCount(success: @escaping (InstapickAnalyzesCount) -> ()) {
        instapickService.getAnalyzesCount { [weak self] result in
            switch result {
            case .success(let analysisCount):
                success(analysisCount)
            case .failed(let error):
                self?.showError(message: error.description)
            }
        }
    }
    
    private func prepareToOpenDetails(with analyze: InstapickAnalyze) {
        startActivityIndicator()
        getAnalyzesCount(success: { [weak self] analyzesCount in
            self?.getAnalyzeDetails(for: analyze.requestIdentifier, analyzesCount: analyzesCount)
        })
    }
    
    private func openDetail(for analysis: [InstapickAnalyze], analyzesCount: InstapickAnalyzesCount) {
        stopActivityIndicator()
        
        let router = RouterVC()
        let controller = router.instaPickDetailViewController(models: analysis, analyzesCount: analyzesCount, isShowTabBar: false)
        
        router.presentViewController(controller: controller)
    }
    
    private func showError(message: String) {
        stopActivityIndicator()
        DispatchQueue.toMain {
            UIApplication.showErrorAlert(message: message)
        }
    }
}

extension AnalyzeHistoryViewController: ActivityIndicator {
    func startActivityIndicator() {
        activityManager.start()
    }
    
    func stopActivityIndicator() {
        activityManager.stop()
    }
}

// MARK: - AnalyzeHistoryDataSourceDelegate

extension AnalyzeHistoryViewController: AnalyzeHistoryDataSourceDelegate {
    func needLoadNextHistoryPage() {
        loadNextHistoryPage()
    }
    
    func onLongPressInCell() {
        startSelection(with: 1)
    }
    
    func onPurchase() {
        InstaPickRoutingService.openPremium()
    }
    
    func onSeeDetails() {
        InstaPickRoutingService.openPremium()
    }
    
    func onSelectAnalyze(_ analyze: InstapickAnalyze) {
        prepareToOpenDetails(with: analyze)
    }
    
    func onUpdateSelectedItems(count: Int) {
        selectedItemsCountChange(with: count)
    }
}

extension AnalyzeHistoryViewController: AnalyzeHistoryTabBarPresenterDelegate {
    func bottomBarSelectedItem(_ item: ElementTypes) {
        switch item {
        case .delete:
            deleteAction()
        default:
            break
        }
    }
}

extension AnalyzeHistoryViewController: InstaPickServiceDelegate {
    func didRemoveAnalysis() { }
    
    func didFinishAnalysis(_ analyses: [InstapickAnalyze]) {
        guard let mainAnalyse = analyses.max(by: {
            if $0.rank == $1.rank {
                return $0.score < $1.score
            }
            return $0.rank < $1.rank
        }) else {
            return
        }
        
        let insertAnalyse = InstapickAnalyze(requestIdentifier: mainAnalyse.requestIdentifier,
                                             rank: mainAnalyse.rank,
                                             hashTags: mainAnalyse.hashTags,
                                             fileInfo: mainAnalyse.fileInfo,
                                             photoCount: analyses.count,
                                             startedDate: mainAnalyse.startedDate,
                                             score: mainAnalyse.score)
        
        if dataSource.isEmpty {
            displayManager.applyConfiguration(.initial)
        }
        
        dataSource.insertNewItems([insertAnalyse])
    }
    
    private func handleAnalyzeResultAfterProgressPopUp(analyzesResult: AnalyzeResult) {
        
        instaPickCampaignService.getController { [weak self] navController in
            DispatchQueue.toMain {
                if let navController = navController,
                    let controller = navController.topViewController as? InstaPickCampaignViewController
                {
                    controller.didClosed = {
                        self?.showResultWithoutCampaign(analyzesCount: analyzesResult.analyzesCount, analysis: analyzesResult.analysis)
                    }
                    self?.stopActivityIndicator()
                    self?.present(navController, animated: true, completion: nil)
                } else {
                    self?.showResultWithoutCampaign(analyzesCount: analyzesResult.analyzesCount, analysis: analyzesResult.analysis)
                }
            }
        }
    }
    
    private func showResultWithoutCampaign(analyzesCount: InstapickAnalyzesCount, analysis: [InstapickAnalyze]) {
        
        updateAnalyzeCount(with: analyzesCount)
        let instapickDetailControlller = router.instaPickDetailViewController(models: analysis,
                                                                              analyzesCount: analyzesCount,
                                                                              isShowTabBar: self.isGridRelatedController(controller: router.getViewControllerForPresent()))
        stopActivityIndicator()
        present(instapickDetailControlller, animated: true, completion: nil)
    }
    
    private func isGridRelatedController(controller: UIViewController?) -> Bool {
        guard let controller = controller else {
            return false
        }
        return (controller is BaseFilesGreedViewController || controller is SegmentedController)
    }
}

extension AnalyzeHistoryViewController: InstaPickProgressPopupDelegate {
    func analyzeDidComplete(analyzeResult: AnalyzeResult) {
        startActivityIndicator()
        handleAnalyzeResultAfterProgressPopUp(analyzesResult: analyzeResult)
    }
}
