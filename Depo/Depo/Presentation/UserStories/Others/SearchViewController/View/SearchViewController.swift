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
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
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
    
    let underNavBarBarHeight: CGFloat = 53
    let musicBar = MusicBar(frame: CGRect.zero)
    
    // MARK: - Variables
    var underNavBarBar: GridListTopBar?
    var output: SearchViewOutput!
    
    var suggestionList = [SuggestionObject]()
    var recentSearchList = [RecentSearchesObject]()
    
    var tabBarActionHandler: TabBarActionHandler? { return output.tabBarActionHandler }
    
    var searchBar: UISearchBar!
    var navBarConfigurator = NavigationBarConfigurator()
    var editingTabBar: BottomSelectionTabBarViewController?
    
    // MARK: - Life Cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        view.backgroundColor = .clear
        collectionView.isHidden = true
        noFilesLabel.text = TextConstants.noFilesFoundInSearch
        topBarContainer.isHidden = true
       
        setupMusicBar()
        subscribeToNotifications()
        configureNavigationBar()
        setCurrentPlayState()
        configureTableView()
        setupBlurBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        defaultNavBarStyle()
        setStatusBarBackgroundColor(color: .white)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.statusBarStyle = .default
        
        editingTabBar?.view.layoutIfNeeded()
        
        let allVisibleCells = collectionView.indexPathsForVisibleItems
        if !allVisibleCells.isEmpty {
            collectionView.performBatchUpdates({
                collectionView.reloadItems(at: allVisibleCells)
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        output.viewWillDisappear()
        setStatusBarBackgroundColor(color: .clear)
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
    
    private func setCurrentPlayState() {
        var hidden = true
        if collectionView.isHidden == true {
            hidden = true
        } else {
            if output.player.isPlaying {
                hidden = false
            }
        }
        if !hidden {
            showMusicBar()
        } else {
            hideMusicBar(self)
        }
    }
    
    private func changeVisibleStatus(hidden: Bool) {
        musicBarContainer.isHidden = hidden
        musicBarContainer.isUserInteractionEnabled = !hidden
    }
    
    // MARK: - Configuration
    
    private func configureTableView() {
        suggestTableView.register(UINib(nibName: CellsIdConstants.suggestionTableSectionHeaderID, bundle: nil),
                                  forHeaderFooterViewReuseIdentifier: CellsIdConstants.suggestionTableSectionHeaderID)
        
        suggestTableView.register(UINib(nibName: CellsIdConstants.suggestionTableViewCellID, bundle: nil),
                                  forCellReuseIdentifier: CellsIdConstants.suggestionTableViewCellID)
        
        suggestTableView.backgroundColor = .clear
        suggestTableView.separatorColor = .white
    }
    
    private func setupBlurBackground() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)
    }
    
    private func configureNavigationBar() {
        navigationBar.topItem?.rightBarButtonItems = []
        
        searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        searchBar.tintColor = ColorConstants.darcBlueColor
        searchBar.delegate = self
        searchBar.setImage(UIImage(named: TextConstants.searchIcon), for: .search, state: .normal)
        searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        for subView in (searchBar.subviews.first?.subviews)! {
            if subView.isKind(of: UITextField.self) {
                let textFileld = (subView as! UITextField)
                textFileld.backgroundColor = ColorConstants.searchBarColor
                textFileld.placeholder = TextConstants.search
                textFileld.font = UIFont.TurkcellSaturaBolFont(size: 19)
                textFileld.textColor = ColorConstants.darcBlueColor
                textFileld.keyboardAppearance = .dark
            }
            if subView.isKind(of: UIButton.self) {
                (subView as! UIButton).titleLabel?.font = UIFont.TurkcellSaturaRegFont(size: 17)
            }
        }
        
        setupNavigationBarForSelectionState(state: false)
        searchBar.becomeFirstResponder()
        output.viewIsReady(collectionView: collectionView)
    }
    
    private func setupNavigationBarForSelectionState(state: Bool) {
        if state {
            navigationBar.topItem?.titleView = nil
            
            let cancelButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 56))
            cancelButton.addTarget(self, action: #selector(onCancelSelectionButton), for: .touchUpInside)
            cancelButton.setTitle(TextConstants.cancelSelectionButtonTitle, for: .normal)
            cancelButton.setTitleColor(ColorConstants.darcBlueColor, for: .normal)
            cancelButton.titleLabel?.font = UIFont.TurkcellSaturaDemFont(size: 19)
            
            let moreButton = UIBarButtonItem(image: UIImage(named: TextConstants.moreBtnImgName), style: .plain, target: self, action: #selector(onMoreButton(_:)))
            moreButton.tintColor = ColorConstants.darcBlueColor
            moreButton.accessibilityLabel = TextConstants.accessibilityMore

            navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
            navigationBar.topItem?.rightBarButtonItem = moreButton            
        } else {
            if Device.isIpad {
                navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: TextConstants.cancel, style: .plain, target: self, action: #selector(searchBarCancelButtonClicked(_:)))
                navigationBar.topItem?.rightBarButtonItem?.tintColor = ColorConstants.darcBlueColor
            } else {
                navigationBar.topItem?.rightBarButtonItem = nil
            }
            navigationBar.topItem?.title = ""
            navigationBar.topItem?.titleView = searchBar
            navigationBar.topItem?.leftBarButtonItem = nil
        }
    }
    
    @objc func onCancelSelectionButton() {
        output.tapCancel()
    }
    
    @objc func onMoreButton(_ sender: UIBarButtonItem) {
        output.moreActionsPressed(sender: sender)
    }
    
    func selectedItemsCountChange(with count: Int) {
        navigationBar.topItem?.title = "\(count) \(TextConstants.accessibilitySelected)"
    }
    
    // MARK: - UISearchbarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        dismissController()
        output.tapCancel()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        search(text: searchBar.text, type: nil)
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
            noFilesView.isHidden = true
            topBarContainer.isHidden = true
        }
    }
    
    func endSearchRequestWith(text: String) {
        collectionView.isHidden = !noFilesView.isHidden
        setCurrentPlayState()
        
        if let searchBar = navigationBar.topItem?.titleView as? UISearchBar, let searchBarText = searchBar.text {
            let requestText = text.removingPercentEncoding ?? text
            if requestText != searchBarText {
                timerToSearch.invalidate()
                timerToSearch = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(searchTimerIsOver(timer:)), userInfo: text, repeats: false)
            }
        }

        topBarContainer.isHidden = false
    }
    
    private func search(text: String?, type: SuggestionType?) {
        if let searchText = text, !searchText.isEmpty {
            output.searchWith(searchText: searchText, type: type, sortBy: SortType.date, sortOrder: SortOrder.asc)
        } else {
            collectionView.isHidden = true
            setCurrentPlayState()
        }
        view.endEditing(true)
        suggestTableView.isHidden = true
        searchBar.enableCancelButton()
    }
    
    // MARK: - SearchViewInput
    
    func getCollectionViewWidth() -> CGFloat{
        return collectionView.frame.size.width
    }
    
    func setCollectionViewVisibilityStatus(visibilityStatus: Bool){
        collectionView.isHidden = visibilityStatus
        noFilesView.isHidden = !visibilityStatus
        setCurrentPlayState()
    }
    
    func successWithSuggestList(list: [SuggestionObject]) {
        suggestionList = list
        suggestTableView.isHidden = suggestionList.count == 0 && recentSearchList.count == 0
        suggestTableView.reloadData()
    }
    
    func setRecentSearches(_ recentSearches: [RecentSearchesObject]) {
        recentSearchList = recentSearches
        suggestTableView.reloadData()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    func dismissController() {
        dismiss(animated: true, completion: nil)
    }
    
    func onSetSelection(state: Bool) {
        setupNavigationBarForSelectionState(state: state)
    
    }
    
    func setNavBarRigthItem(active isActive: Bool) {
        navigationBar.topItem?.rightBarButtonItem?.isEnabled = isActive
    }
    
    //MARK: - Under nav bar
    
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
    
}

//MARK: - UITableViewDelagate & DataSource 

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let category = SuggestionTableSectionHeader.Category(rawValue: section) else {
            return 0
        }
        switch category {
        case .suggestion:
            return suggestionList.count
        case .recent:
            return recentSearchList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.suggestionTableViewCellID, for: indexPath) as? SuggestionTableViewCell,
            let category = SuggestionTableSectionHeader.Category(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch category {
        case .recent:
            let recent = recentSearchList[indexPath.row]
            cell.configure(withRecent: recent)
        case .suggestion:
            let suggest = suggestionList[indexPath.row]
            cell.configure(withSuggest: suggest)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CellsIdConstants.suggestionTableSectionHeaderID) as? SuggestionTableSectionHeader
        
        if let category = SuggestionTableSectionHeader.Category(rawValue: section) {
            header?.configureWith(category: category, delegate: self)
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let category = SuggestionTableSectionHeader.Category(rawValue: indexPath.section) else {
            return
        }
        
        let searchText: String
        let type: SuggestionType?
        switch category {
        case .recent:
            let recent = recentSearchList[indexPath.row]
            searchText = recent.text ?? ""
            type = recent.type
        case .suggestion:
            let suggest = suggestionList[indexPath.row]
            searchText = suggest.text ?? ""
            type = suggest.type
        }
        
        let searchBar = navigationBar.topItem?.titleView as! UISearchBar
        searchBar.text = searchText.removingPercentEncoding ?? searchText
        search(text: searchBar.text, type: type)
    }
    
    func musicBarZoomWillOpen() {
        output.willDismissController()
        dismissController()
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
