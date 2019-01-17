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
    
    private let dataSource = AnalyzeHistoryDataSourceForCollectionView()
    private let instapickService: InstapickService = factory.resolve()
    
    private let refresher = UIRefreshControl()
    private var page = 0
    private let pageSize = Device.isIpad ? 50 : 30
    
    private var navBarConfigurator = NavigationBarConfigurator()
    private lazy var cancelSelectionButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onCancelSelectionButton))
    }()
    
    private let navBarRightItemSourceRect = CGRect(x: Device.winSize.width - 45, y: -15, width: 0, height: 0)
    
    private var editingTabBar: BottomSelectionTabBarViewController?
    private var bottomBarPresenter: BottomSelectionTabBarModuleInput?
    private var bottomBarSettablePresenter = AnalyzeHistoryTabBarPresenter()
    private let editingElements: [ElementTypes] = [.delete]
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationBarWithGradientStyle()
        editingTabBar?.view.layoutIfNeeded()
    }
    
    private func configure() {
        needShowTabBar = false
        
        displayManager.applyConfiguration(.initial)
        
        dataSource.setupCollectionView(collectionView: collectionView)
        dataSource.delegate = self
        collectionView.contentInset.bottom = newAnalysisView.bounds.height
        
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
        navigationItem.rightBarButtonItems = navBarConfigurator.rightItems
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
        navigationItem.leftBarButtonItem = cancelSelectionButton
        displayManager.applyConfiguration(.selection)
    }
    
    private func stopSelection() {
        navigationItem.leftBarButtonItem = nil
        setTitle(withString: TextConstants.analyzeHistoryTitle)
        dataSource.cancelSelection()
        bottomBarPresenter?.dismiss(animated: true)
        displayManager.applyConfiguration(dataSource.isEmpty ? .empty : .initial)
    }
    
    private func selectedItemsCountChange(with count: Int) {
        navigationItem.title = "\(count) \(TextConstants.accessibilitySelected)"
        
        if count == 0 {
            bottomBarPresenter?.dismiss(animated: true)
        } else {
            bottomBarPresenter?.show(animated: true, onView: view)
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func newAnalysisAction(_ sender: Any) {
        if dataSource.analysisCount.left > 0 {
            //TODO: - Open New Analyze
        } else {
            let popup = PopUpController.with(title: TextConstants.analyzeHistoryPopupTitle,
                                             message: TextConstants.analyzeHistoryPopupMessage,
                                             image: .custom(UIImage(named: "popup_info")),
                                             buttonTitle: TextConstants.analyzeHistoryPopupButton) { [weak self] controller in
                                                controller.close { [weak self] in
                                                    self?.onPurchase()
                                                }
                                            }

            present(popup, animated: true)
        }
    }
    
    @IBAction private func onCancelSelectionButton(_ sender: Any) {
        stopSelection()
    }
    
    @IBAction private func deleteSelectedItems(_ sender: Any?) {
        deleteSelectedAnalyzes()
    }
    
    private func onMorePressed(_ sender: Any) {
        if dataSource.isSelectionStateActive {
            showAlertSheet(with: [.delete], sender: sender)
        } else {
            showAlertSheet(with: [.select, .selectAll], sender: sender)
        }
    }
    
    private func showAlertSheet(with types: [ElementTypes], sender: Any?) {
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        types.forEach { type in
            var action: UIAlertAction?
            switch type {
            case .delete:
                action = UIAlertAction(title: TextConstants.actionSheetDelete, style: .default, handler: { _ in
                    self.deleteSelectedAnalyzes()
                })
            case .select:
                action = UIAlertAction(title: TextConstants.actionSheetSelect, style: .default, handler: { _ in
                    self.dataSource.startSelection()
                    self.startSelection(with: 0)
                })
            case .selectAll:
                action = UIAlertAction(title: TextConstants.actionSheetSelectAll, style: .default, handler: { _ in
                    self.dataSource.startSelection(with: nil, selectAll: true)
                    self.startSelection(with: self.dataSource.itemsCount)
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
        } else if let _ = sender as? UIBarButtonItem {
            //FIXME: use actionSheetVC.popoverPresentationController?.barButtonItem instead
            if navigationController?.navigationBar.isTranslucent == true {
                var frame = navBarRightItemSourceRect
                frame.origin.y = 44
                actionSheetVC.popoverPresentationController?.sourceRect = frame
            } else {
                actionSheetVC.popoverPresentationController?.sourceRect = navBarRightItemSourceRect
            }
            
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
        
        showSpiner()
        
        reloadCards { [weak self] isSuccess in
            guard let `self` = self else {
                return
            }
            
            if isSuccess {
                self.page = 0
                self.dataSource.isPaginationDidEnd = false
                self.loadNextHistoryPage(completion: { [weak self] _ in
                    self?.hideSpiner()
                })
            } else {
                self.hideSpiner()
            }
        }
    }
    
    private func stopRefresher() {
        if refresher.isRefreshing {
            DispatchQueue.main.async {
                self.refresher.endRefreshing()
            }
        }
    }
    
    private func reloadCards(completion: BoolHandler? = nil) {
        instapickService.getAnalyzesCount { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let analysisCount):
                self.dataSource.reloadCards(with: analysisCount)
                completion?(true)
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
                completion?(false)
            }
        }
    }
    
    private func loadNextHistoryPage(completion: BoolHandler? = nil) {
        instapickService.getAnalyzeHistory(offset: page, limit: pageSize) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let history):
                DispatchQueue.main.async {
                    self.dataSource.appendHistoryItems(history)
                    self.page += 1
                
                    if self.dataSource.isEmpty {
                        self.displayManager.applyConfiguration(.empty)
                    } else if self.displayManager.configuration == .empty {
                        self.displayManager.applyConfiguration(.initial)
                    }
                    completion?(true)
                }
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
                completion?(false)
            }
        }
    }
    
    private func deleteSelectedAnalyzes() {
        let ids = dataSource.selectedItems.map { $0.requestIdentifier }
        instapickService.removeAnalyzes(ids: ids) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.dataSource.deleteSelectedItems(completion: {
                        self.stopSelection()
                    })
                }
            case .failed(let error):
                UIApplication.showErrorAlert(message: error.description)
            }
        }
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
        //TODO: - Open Purchase Screen
    }
    
    func onSeeDetailsForAnalyze(_ analyze: InstapickAnalyze) {
        //TODO: - Open Analyze Details Screen
    }
    
    func onUpdateSelectedItems(count: Int) {
        selectedItemsCountChange(with: count)
    }
}

extension AnalyzeHistoryViewController: AnalyzeHistoryTabBarPresenterDelegate {
    func bottomBarSelectedItem(_ item: ElementTypes) {
        switch item {
        case .delete:
            deleteSelectedAnalyzes()
        default:
            break
        }
    }
}
