//
//  SearchViewController.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, UISearchBarDelegate, SearchViewInput, MusicBarDelegate, TabBarActionHandlerContainer {

    // MARK: - Outlets
    
    @IBOutlet weak var outputView: UIView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var suggestTableView: UITableView!
    
    @IBOutlet weak var noFilesView: UIView!
    @IBOutlet weak var noFilesLabel: UILabel!
    @IBOutlet weak var noFilesImage: UIImageView!
    @IBOutlet weak var startCreatingFilesButton: BlueButtonWithWhiteText!
    
    @IBOutlet weak var topBarContainer: UIView!
    @IBOutlet weak var floatingHeaderContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var musicBarContainer: UIView!
    @IBOutlet weak var musicBarContainerHeightConstraint: NSLayoutConstraint!
    
    private let underNavBarBarHeight: CGFloat = 53
    private let searchSectionCount = 6
    private let minRectFotMusicBar = CGRect(x: 0, y: 0, width: 300, height: 70)
    private lazy var musicBar = MusicBar(frame: minRectFotMusicBar)
    
    // MARK: - Variables
    var underNavBarBar: GridListTopBar?
    var output: SearchViewOutput!
    
    var items = [SearchCategory: [SuggestionObject]]()
    
    var tabBarActionHandler: TabBarActionHandler? { return output.tabBarActionHandler }
    
    var searchBar: UISearchBar!
    var searchTextField: UITextField?
    var navBarConfigurator = NavigationBarConfigurator()
    var editingTabBar: BottomSelectionTabBarViewController?
    
    private var goBack = false
    
    // MARK: - Life Cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.backgroundColor = .clear
        collectionView.isHidden = true
        noFilesLabel.adjustsFontSizeToFitWidth()
        noFilesLabel.text = TextConstants.noFilesFoundInSearch
        topBarContainer.isHidden = true
        
        setupMusicBar()
        configureTableView()
        subscribeToNotifications()
        configureNavigationBar()
        
        if let topBarVc = UIApplication.topController() as? TabBarViewController {
            topBarVc.statusBarStyle = .default
        }
        
        MenloworksTagsService.shared.onSearchOpen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        defaultNavBarStyle()

        statusBarColor = .white
        
        if let topBarVc = UIApplication.topController() as? TabBarViewController {
            topBarVc.statusBarStyle = .default
        }
        
        editingTabBar?.view.layoutIfNeeded()
        
        let allVisibleCells = collectionView.indexPathsForVisibleItems
        if !allVisibleCells.isEmpty {
            collectionView.performBatchUpdates({
                collectionView.reloadItems(at: allVisibleCells)
            })
        }
        navigationItem.hidesBackButton = true
        
        let navBar = navigationController?.navigationBar
        navBar?.barTintColor = UIColor.white
        navBar?.tintColor = ColorConstants.darkBlueColor
        navBar?.setBackgroundImage(UIImage(color: .white), for: .default)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11.0, *), Device.operationSystemVersionLessThen(13) {
            defaultNavBarStyle()
            statusBarColor = .white
        }
        
        navigationController?.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchBar.resignFirstResponder()

        statusBarColor = .clear
        
        if goBack {
            if let topBarVc = UIApplication.topController() as? TabBarViewController {
                topBarVc.statusBarStyle = .lightContent
            }
        }
        
        output.viewWillDisappear()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    deinit {
        unSubscribeFromNotifications()
    }
    
    fileprivate func subscribeToNotifications() {
        let dropNotificationName = NSNotification.Name(rawValue: TabBarViewController.notificationMusicDrop)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(hideMusicBar),
                                               name: dropNotificationName,
                                               object: nil)
    }
    
    fileprivate func unSubscribeFromNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupMusicBar() {
        musicBarContainer.addSubview(musicBar)
        let horisontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[item1]-(0)-|",
                                                                   options: [], metrics: nil,
                                                                   views: ["item1" : musicBar])
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[item1]-(0)-|",
                                                                 options: [], metrics: nil,
                                                                 views: ["item1" : musicBar])
        
        musicBarContainer.addConstraints(horisontalConstraints + verticalConstraints)
        changeVisibleStatus(hidden: true)
        musicBar.delegate = self
    }
    
    
    func showMusicBar() {
        musicBar.configurateFromPLayer()
        changeVisibleStatus(hidden: false)
        collectionView.contentInset.bottom = musicBarContainerHeightConstraint.constant
    }
    
    @objc func hideMusicBar(_ sender: Any) {
        collectionView.contentInset.bottom = 0
        changeVisibleStatus(hidden: true)
        output.playerDidHide()
    }
    
    private func changeVisibleStatus(hidden: Bool) {
        musicBarContainer.isHidden = hidden
        musicBarContainer.isUserInteractionEnabled = !hidden
    }
    
    // MARK: - Configuration
    
    private func configureTableView() {
        suggestTableView.register(UINib(nibName: CellsIdConstants.suggestionTableSectionHeaderID, bundle: nil),
                                  forCellReuseIdentifier: CellsIdConstants.suggestionTableSectionHeaderID)
        
        suggestTableView.register(UINib(nibName: CellsIdConstants.suggestionTableViewCellID, bundle: nil),
                                  forCellReuseIdentifier: CellsIdConstants.suggestionTableViewCellID)
        
        suggestTableView.register(UINib(nibName: CellsIdConstants.recentlySearchedTableViewCellID, bundle: nil),
                                  forCellReuseIdentifier: CellsIdConstants.recentlySearchedTableViewCellID)
        
        suggestTableView.backgroundColor = .clear
        suggestTableView.separatorColor = .white
        suggestTableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        suggestTableView.tableFooterView = UIView()
        suggestTableView.sectionHeaderHeight = 0
    }
    
    private func configureNavigationBar() {
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItems = []
        
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        searchBar.backgroundImage = UIImage(color: ColorConstants.searchBarColor)
        searchBar.tintColor = ColorConstants.darkBlueColor
        searchBar.delegate = self
        searchBar.setImage(UIImage(named: TextConstants.searchIcon), for: .search, state: .normal)
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Device.winSize.width, height: 44))
        view.backgroundColor = .white
        searchBar.addSubview(view)
        searchBar.sendSubview(toBack: view)
        
        let firstTextField = searchBar.firstSubview(of: UITextField.self)
        
        if let textField = firstTextField {
            textField.backgroundColor = ColorConstants.searchBarColor
            textField.placeholder = TextConstants.search
            textField.font = UIFont.TurkcellSaturaBolFont(size: 19)
            textField.textColor = ColorConstants.darkBlueColor
            textField.keyboardAppearance = .dark
            searchTextField = textField
        }
        
        let cancelButton = searchBar.firstSubview(of: UIButton.self)
        
        if let button = cancelButton {
            button.titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 17)
            button.isEnabled = true
            button.adjustsFontSizeToFitWidth()
        }
        
        setupNavigationBarForSelectionState(state: false)
        
        output.viewIsReady(collectionView: collectionView)
    }
    
    private func setupNavigationBarForSelectionState(state: Bool) {
        if state {
            navigationItem.titleView = nil

            navigationItem.leftBarButtonItem = UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                                                               font: .TurkcellSaturaDemFont(size: 19.0),
                                                               tintColor: ColorConstants.darkBlueColor,
                                                               target: self,
                                                               selector: #selector(onCancelSelectionButton))

            let moreButton = UIBarButtonItem(image: UIImage(named: TextConstants.moreBtnImgName),
                                             style: .plain,
                                             target: self,
                                             action: #selector(onMoreButton(_:)))
            moreButton.tintColor = ColorConstants.darkBlueColor
            moreButton.accessibilityLabel = TextConstants.accessibilityMore

            navigationItem.rightBarButtonItem = moreButton
        } else {
            if Device.isIpad {
                navigationItem.rightBarButtonItem = UIBarButtonItem(
                    title: TextConstants.cancel,
                    tintColor: ColorConstants.darkBlueColor,
                    target: self,
                    selector: #selector(searchBarCancelButtonClicked(_:)))
            } else {
                navigationItem.rightBarButtonItem = nil
            }
            
            DispatchQueue.main.async {
                self.navigationItem.title = ""
                self.navigationItem.titleView = self.searchBar
                self.navigationItem.leftBarButtonItem = nil
                self.navigationItem.titleView?.setNeedsLayout()
                self.navigationItem.titleView?.layoutIfNeeded()
            }
        }
    }
    
    @objc func onCancelSelectionButton() {
        output.tapCancel()
    }
    
    @objc func onMoreButton(_ sender: UIBarButtonItem) {
        output.moreActionsPressed(sender: sender)
    }
    
    func selectedItemsCountChange(with count: Int) {
        navigationItem.title = "\(count) \(TextConstants.accessibilitySelected)"
    }
    
    // MARK: - UISearchbarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        dismissController(animated: true)
        output.tapCancel()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(text: searchBar.text)
    }
    
    var timerToSearch = Timer()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !output.isShowedSpinner() {
            timerToSearch.invalidate()
            timerToSearch = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(searchTimerIsOver(timer:)), userInfo: searchText, repeats: false)
        }
    }
    
    @objc func searchTimerIsOver(timer: Timer) {
        if let searchText = timer.userInfo as? String {
            output.getSuggestion(text: searchText)
            collectionView.isHidden = true
            suggestTableView.isHidden = isEmptyItems()
            noFilesView.isHidden = true
            topBarContainer.isHidden = true
            hideTabBar()
        }
    }
    
    func endSearchRequestWith(text: String) {
        collectionView.isHidden = !noFilesView.isHidden
        
        if let searchBar = navigationItem.titleView as? UISearchBar, let searchBarText = searchBar.text {
            let requestText = text.removingPercentEncoding ?? text
            if requestText != searchBarText {
                timerToSearch.invalidate()
                timerToSearch = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(searchTimerIsOver(timer:)), userInfo: text, repeats: false)
            }
        }

        topBarContainer.isHidden = false
    }
    
    private func search(text: String?, forItem item: SuggestionObject? = nil) {
        if let searchText = text, !searchText.isEmpty {
            output.searchWith(searchText: searchText, item: item, sortBy: .date, sortOrder: .asc)
        } else {
            collectionView.isHidden = true
        }
        searchBar.resignFirstResponder()
        searchBar.enableCancelButton()
        suggestTableView.isHidden = true
    }
    
    // MARK: - SearchViewInput
    
    func getCollectionViewWidth() -> CGFloat {
        return collectionView.frame.size.width
    }
    
    func setCollectionViewVisibilityStatus(visibilityStatus: Bool) {
        collectionView.isHidden = visibilityStatus
        noFilesView.isHidden = !visibilityStatus
    }
    
    func successWithSuggestList(list: [SuggestionObject]) {
        items[.suggestion] = Array(list.prefix(NumericConstants.maxSuggestions))
        
        DispatchQueue.toMain {
            if self.collectionView.isHidden && self.noFilesView.isHidden {
                self.suggestTableView.isHidden = self.isEmptyItems()
            }
            
            self.suggestTableView.reloadData()
        }
    }
    
    func setRecentSearches(_ recentSearches: [SearchCategory: [SuggestionObject]]) {
        recentSearches.forEach { category, list in
            self.items[category] = list
        }
        
        DispatchQueue.toMain {
            self.suggestTableView.reloadData()
        }
    }
    
    private func isEmptyItems() -> Bool {
        for list in items.values {
            if !list.isEmpty { return false }
        }
        return true
    }
    
    private func isEmptyItemsCategory(_ category: SearchCategory) -> Bool {
        return items[category] == nil || items[category]!.isEmpty
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    func dismissController(animated: Bool) {
        goBack = true
        navigationController?.delegate = self
        navigationController?.popViewController(animated: animated)
    }
    
    func onSetSelection(state: Bool) {
        setupNavigationBarForSelectionState(state: state)
    }
    
    func setNavBarRigthItem(active isActive: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isActive
    }
    
    func setEnabledSearchBar(_ isEnabled: Bool) {
        searchBar.isUserInteractionEnabled = isEnabled
        searchBar.alpha = isEnabled ? 1 : 0.5
    }
    
    func setVisibleTabBar(_ isVisible: Bool) {
        if isVisible {
            showTabBar()
        } else {
            hideTabBar()
        }
    }
    
    // MARK: - Under nav bar
    
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
        view.layoutIfNeeded()
    }
    
    // MARK: - Keyboard
    
    @objc override func showKeyBoard(notification: NSNotification) {
        super.showKeyBoard(notification: notification)
        
        suggestTableView.contentInset.bottom = keyboardHeight
        collectionView.contentInset.bottom = keyboardHeight
    }
    
    @objc override func hideKeyboard() {
        suggestTableView.contentInset = .zero
        collectionView.contentInset = .zero
    }
    
    // MARK: - TabBar
    
    private func showTabBar() {
        needToShowTabBar = true
        showTabBarIfNeeded()
    }
    
    private func hideTabBar() {
        needToShowTabBar = false
        showTabBarIfNeeded()
    }
    
    func showSpiner() {
        searchTextField?.isUserInteractionEnabled = false
        showSpinnerOnView(outputView)
    }
    
    func hideSpiner() {
        searchTextField?.isUserInteractionEnabled = true
        hideSpinerForView(outputView)
    }
}

// MARK: - UITableViewDelagate & DataSource 

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchSectionCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let category = SearchCategory(rawValue: section) else {
            return 0
        }
        
        switch category {
        case .suggestion, .recent:
            return items[category]?.count ?? 0
        case .suggestionHeader, .recentHeader, .people, .things:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let category = SearchCategory(rawValue: indexPath.section) else {
            return UITableViewAutomaticDimension
        }
        
        switch category {
        case .suggestion, .recent:
            return UITableViewAutomaticDimension
        case .people, .things:
            if !isEmptyItemsCategory(category) {
                return RecentlySearchedFaceImageTableViewCell.height()
            }
            return 0
        case .suggestionHeader:
            return SuggestionTableSectionHeader.heightFor(category: category)
        case .recentHeader:
            if !isEmptyItemsCategory(.recent) || !isEmptyItemsCategory(.people) || !isEmptyItemsCategory(.things) {
                return SuggestionTableSectionHeader.heightFor(category: category)
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let category = SearchCategory(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch category {
        case .suggestionHeader, .recentHeader:
            if let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.suggestionTableSectionHeaderID, for: indexPath) as?  SuggestionTableSectionHeader {
                cell.configureWith(category: category, delegate: self)
                return cell
            }
        
        case .recent, .suggestion:
            if let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.suggestionTableViewCellID, for: indexPath) as? SuggestionTableViewCell,
                let item = items[category]?[indexPath.item] {
                cell.configure(with: item, recent: category == .recent)
                return cell
            }
        case .people, .things:
            if let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.recentlySearchedTableViewCellID, for: indexPath) as? RecentlySearchedFaceImageTableViewCell {
                cell.configure(withItems: items[category], category: category)
                cell.delegate = self
                return cell
            }
        }
        return UITableViewCell()
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let category = SearchCategory(rawValue: indexPath.section),
            category == .recent || category == .suggestion else {
            return
        }
        guard let item = items[category]?[indexPath.item] else {
            return
        }
        
        if item.info?.id != nil, let type = item.type, type.isFaceImageType() {
            output.openFaceImage(item: item)
        } else if let searchBar = navigationItem.titleView as? UISearchBar {
            searchBar.text = item.text?.removingPercentEncoding ?? item.text
            search(text: searchBar.text, forItem: item)
        }
    }
    
    func musicBarZoomWillOpen() {
        output.willDismissController()
        dismissController(animated: true)
    }
}

extension SearchViewController: MediaPlayerDelegate {
    func mediaPlayer(_ mediaPlayer: MediaPlayer, didStartItemWith duration: Float) {
        showMusicBar()
    }
    func mediaPlayer(_ musicPlayer: MediaPlayer, changedCurrentTime time: Float) {}
    func didStartMediaPlayer(_ mediaPlayer: MediaPlayer) {}
    func didStopMediaPlayer(_ mediaPlayer: MediaPlayer) {}
}


extension SearchViewController: GridListTopBarDelegate {
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

extension SearchViewController: SuggestionTableSectionHeaderDelegate {
    
    func onClearRecentSearchesTapped() {
        output.onClearRecentSearchesTapped()
    }
    
}

extension SearchViewController: RecentlySearchedFaceImageCellDelegate {

    func select(item: SuggestionObject) {
        output.openFaceImage(item: item)
    }
    
    func tapArrow(category: SearchCategory) {
        output.openFaceImageItems(category: category)
    }
    
}
