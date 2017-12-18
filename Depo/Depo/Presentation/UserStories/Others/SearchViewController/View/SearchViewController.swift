//
//  SearchViewController.swift
//  Depo
//
//  Created by Максим Деханов on 10.08.17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, SearchViewInput, MusicBarDelegate {
    
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
     let underNavBarBarHeight: CGFloat = 53
    
    let musicBar = MusicBar.initFromXib()

    @IBOutlet weak var musicBarContainer: UIView!
    @IBOutlet weak var musicBarContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!

    // MARK: - Variables
    var underNavBarBar: GridListTopBar?
    var output: SearchViewOutput!
    
    var suggestionList = [SuggestionObject]()
    var recentSearchList = [String]()
    
    // MARK: - Life Cicle

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isOpaque = false
        self.view.backgroundColor = ColorConstants.searchShadowColor
        self.collectionView.isHidden = true
        self.noFilesLabel.text = TextConstants.noFilesFoundInSearch
        self.topBarContainer.isHidden = true
       
        suggestTableView.register(UINib(nibName: CellsIdConstants.suggestionTableSectionHeaderID, bundle: nil),
                                  forCellReuseIdentifier: CellsIdConstants.suggestionTableSectionHeaderID)
        suggestTableView.contentInset.top = 20
        
        setupMusicBar()
        subscribeToNotifications()
        configureNavigationBar()
        setCurrentPlayState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
    }
    
    deinit {
        self.unSubscribeFromNotifications()
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
        containerViewBottomConstraint.constant = musicBarContainerHeightConstraint.constant
    }
    
    @objc func hideMusicBar(_ sender: Any) {
        containerViewBottomConstraint.constant = 0
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
    
    func configureNavigationBar() {
        self.navigationBar.topItem?.rightBarButtonItems = []
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        searchBar.tintColor = ColorConstants.darcBlueColor
        searchBar.delegate = self
        searchBar.setImage(UIImage(named: TextConstants.searchIcon), for: .search, state: .normal)
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
        if Device.isIpad {
            self.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: TextConstants.cancel, style: .plain, target: self, action: #selector(self.searchBarCancelButtonClicked(_:)))
            self.navigationBar.topItem?.rightBarButtonItem?.tintColor = ColorConstants.darcBlueColor
        }
        self.navigationBar.topItem?.titleView = searchBar
        searchBar.becomeFirstResponder()
        output.viewIsReady(collectionView: collectionView)
    }
    
    // MARK: - UISearchbarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        dismissController()
        output.tapCancel()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text! != "" {
            let customAllowedSet =  CharacterSet(charactersIn:"=\"#%/<>?@\\^`{|}&").inverted
            output.searchWith(searchText: searchBar.text!.addingPercentEncoding(withAllowedCharacters: customAllowedSet)!, sortBy: SortType.date, sortOrder: SortOrder.asc)
        } else {
            collectionView.isHidden = true
            setCurrentPlayState()
        }
        view.endEditing(true)
        suggestTableView.isHidden = true
    }
    
    var timerToSearch = Timer()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !output.isShowedSpinner() {
            self.timerToSearch.invalidate()
            self.timerToSearch = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.searchTimerIsOver(timer:)), userInfo: searchText, repeats: false)
        }
    }
    
    @objc func searchTimerIsOver(timer: Timer) {
        self.output.getSuggestion(text: timer.userInfo as! String)
    }
    
    func endSearchRequestWith(text: String) {
        self.collectionView.isHidden = false
        setCurrentPlayState()
        if let searchBar = self.navigationBar.topItem?.titleView {
            if text != (searchBar as! UISearchBar).text! {
                self.timerToSearch.invalidate()
                self.timerToSearch = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.searchTimerIsOver(timer:)), userInfo: (searchBar as! UISearchBar).text!, repeats: false)
            }
        }
        
        self.topBarContainer.isHidden = false
    }
    
    // MARK: - SearchViewInput
    
    func getCollectionViewWidth() -> CGFloat{
        return collectionView.frame.size.width
    }
    
    func setCollectionViewVisibilityStatus(visibilityStatus: Bool){
        collectionView.isHidden = visibilityStatus
        noFilesView.isHidden = !visibilityStatus
        noFilesLabel.isHidden = !visibilityStatus
        setCurrentPlayState()
    }
    
    func successWithSuggestList(list: [SuggestionObject]) {
        suggestionList = list
        suggestTableView.isHidden = suggestionList.count == 0 && recentSearchList.count == 0
        suggestTableView.reloadData()
    }
    
    func setRecentSearches(_ recentSearches: [String]) {
        recentSearchList = recentSearches
        suggestTableView.reloadData()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func dismissController() {
        navigationController?.popViewController(animated: false)
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
        let cell = UITableViewCell()
        guard let category = SuggestionTableSectionHeader.Category(rawValue: indexPath.section) else {
            return cell
        }
        cell.textLabel?.font = UIFont.TurkcellSaturaDemFont(size: 15)
        cell.textLabel?.textColor = ColorConstants.darcBlueColor
        
        switch category {
        case .recent:
            cell.textLabel?.text = recentSearchList[indexPath.row]
        case .suggestion:
            let suggest = suggestionList[indexPath.row]
            if let text = suggest.highlightedText {
                cell.textLabel?.attributedText = text
            } else {
                cell.textLabel?.text = suggest.text!
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: CellsIdConstants.suggestionTableSectionHeaderID) as? SuggestionTableSectionHeader
        
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
        switch category {
        case .recent:
            searchText = recentSearchList[indexPath.row]
        case .suggestion:
            searchText = suggestionList[indexPath.row].text!
        }
        
        let searchBar = navigationBar.topItem?.titleView as! UISearchBar
        searchBar.text = searchText
        searchBarSearchButtonClicked(searchBar)
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








