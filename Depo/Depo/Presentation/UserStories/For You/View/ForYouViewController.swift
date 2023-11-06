//
//  ForYouViewController.swift
//  Depo
//
//  Created by Burak Donat on 22.07.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import Foundation

final class ForYouViewController: BaseViewController {
    
    //MARK: -Properties
    var output: ForYouViewOutput!
    private lazy var forYouSections: [ForYouSections] = []
    private lazy var isFIREnabled: Bool = false
    private lazy var shareCardContentManager = ShareCardContentManager(delegate: self)
    
    //MARK: -IBOutlet
    @IBOutlet private weak var tableView: UITableView!
    
    var refresher: UIRefreshControl?
    
    //MARK: -Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("ForYou viewDidLoad")
        
        configureUI()
        configureTableView()
        output.checkFIRisAllowed()
        output.viewIsReady()
        setupRefresher()
        NotificationCenter.default.addObserver(self,selector: #selector(getUpdateDataHiddenFav),name: .foryouGetUpdateData, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let isTimeline = UserDefaults.standard.bool(forKey: "TimelineVideoDelete")
        if isTimeline {
            updateTableView(for: .timeline)
            UserDefaults.standard.set(false, forKey: "TimelineVideoDelete")
        }
    }
    
    @objc func getUpdateDataHiddenFav(){
        output.getUpdateData(for: ForYouSections.hidden)
        output.getUpdateData(for: ForYouSections.favorites)
        output.getHeightForRow(at: ForYouSections.timeline)
        fullReload()
    }
    
    private func setupRefresher() {
        refresher = UIRefreshControl()
        refresher?.tintColor = AppColor.filesRefresher.color
        refresher?.addTarget(self, action: #selector(fullReload), for: .valueChanged)
        tableView.refreshControl = refresher
    }
    
    @objc private func fullReload() {
        output.viewIsReady()
        stopRefresher()
    }
    
    func stopRefresher() {
        tableView.refreshControl?.endRefreshing()
     }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentSection = output.currentSection else {
            return
        }
        output.getUpdateData(for: currentSection)
        if currentSection == .albums {
            tableView.reloadData()
        }
        if currentSection == .things {
            tableView.reloadData()
        }
        if currentSection == .places {
            tableView.reloadData()
        }
    }
    
    deinit {
        ItemOperationManager.default.stopUpdateView(view: self)
    }
    
    //MARK: -Helpers
    private func configureUI() {
        navigationBarHidden = true
        needToShowTabBar = true
        setDefaultNavigationHeaderActions()
        headerContainingViewController?.isHeaderBehindContent = false
        ItemOperationManager.default.startUpdateView(view: self)
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(nibCell: ForYouTableViewCell.self)
        tableView.register(nibCell: ForYouFaceImageTableViewCell.self)
        tableView.register(nibCell: ForYouTimelineTableViewCell.self)
    }
    
    private func faceImagePermissionChanged(to isAllowed: Bool) {
        forYouSections = ForYouSections.allCases

        if !isAllowed {
            forYouSections.remove(.people)
            forYouSections.remove(.things)
        } else {
            forYouSections.remove(.faceImage)
        }
        
        isFIREnabled = isAllowed
    }
    
    private func updateTableView(for view: ForYouSections) {
        guard let index = forYouSections.firstIndex(of: view) else { return }
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
}

//MARK: -ForYouViewInput
extension ForYouViewController: ForYouViewInput {
    func getFIRResponse(isAllowed: Bool) {
        faceImagePermissionChanged(to: isAllowed)
    }
    
    func didFinishedAllRequests() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didGetUpdateData() {
        guard let currentSection = output.currentSection else {
            updateTableView(for: .hidden)
            updateTableView(for: .favorites)
            return
        }
        updateTableView(for: currentSection)
    }
    
    func saveCardFailed(section: ForYouSections) {
        updateTableView(for: section)
    }
    
    func saveCardSuccess(section: ForYouSections) {
        if section == .collageCards {
            output.getUpdateData(for: .collages)
        } else if section == .animationCards {
            output.getUpdateData(for: .animations)
        } else if section == .albumCards {
            output.getUpdateData(for: .albums)
        } else if section == .timeline {
            output.getUpdateData(for: .timeline)
        }
    }
}

//MARK: -UITableViewDataSource
extension ForYouViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forYouSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let timelineEnable = FirebaseRemoteConfig.shared.fetchTimelineEnabled
        if timelineEnable && indexPath.row == 0 {
            let cell = tableView.dequeue(reusable: ForYouTimelineTableViewCell.self, for: indexPath)
            let model = output.getModel(for: forYouSections[indexPath.row]) as? TimelineResponse
            cell.delegate = self
            cell.configure(with: model)
            cell.isHidden = model != nil ? false : true
            return cell
        } else if !isFIREnabled && indexPath.row == 1 {
            let cell = tableView.dequeue(reusable: ForYouFaceImageTableViewCell.self, for: indexPath)
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeue(reusable: ForYouTableViewCell.self, for: indexPath)
            let model = output.getModel(for: forYouSections[indexPath.row])
            cell.configure(with: model, currentView: forYouSections[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
}

//MARK: -UITableViewDelegate
extension ForYouViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(output.getHeightForRow(at: forYouSections[indexPath.row]))
    }
}

//MARK: -ForYouTableViewCellDelegate
extension ForYouViewController: ForYouTableViewCellDelegate {
    func navigateToCreateCollage() {
        output.navigateToCreateCollage()
    }
    
    func navigateToThrowbackDetail(item: ThrowbackData, completion: @escaping VoidHandler) {
        output.navigateToThrowbackDetail(item: item, completion: completion)
    }
    
    func navigateToItemPreview(item: WrapData, items: [WrapData], currentSection: ForYouSections) {
        output.navigateToItemPreview(item: item, items: items, currentSection: currentSection)
    }
    
    func onSeeAllButton(for view: ForYouSections) {
        output.onSeeAllButton(for: view)
    }
    
    func navigateToCreate(for view: ForYouSections) {
        output.navigateToCreate(for: view)
    }
    
    func navigateToItemDetail(item: WrapData, faceImageType: FaceImageType?, currentSection: ForYouSections) {
        output.navigateToItemDetail(item: item, faceImageType: faceImageType, currentSection: currentSection)
    }
    
    func naviateToAlbumDetail(album: AlbumItem) {
        output.navigateToAlbumDetail(album: album)
    }
    
    func displayAlbum(item: AlbumItem) {
        output.displayAlbum(item: item)
    }
    
    func displayAnimation(item: WrapData) {
        output.displayAnimation(item: item)
    }
    
    func displayCollage(item: WrapData) {
        output.displayCollage(item: item)
    }
    
    func onCloseCard(data: HomeCardResponse, section: ForYouSections) {
        output.onCloseCard(data: data, section: section)
    }
    
    func showSavedCollage(item: WrapData) {
        output.showSavedCollage(item: item)
    }
    
    func showSavedAnimation(item: WrapData) {
        output.showSavedAnimation(item: item)
    }
    
    func saveCard(data: HomeCardResponse, section: ForYouSections) {
        output.saveCard(data: data, section: section)
    }
    
    func share(item: BaseDataSourceItem, type: CardShareType) {
        shareCardContentManager.presentSharingMenu(item: item, type: type)
    }
}

//MARK: -HeaderContainingViewControllerChild
extension ForYouViewController: HeaderContainingViewControllerChild {
    var scrollViewForHeaderTracking: UIScrollView? { tableView }
}

//MARK: -ForYouFaceImageTableViewCellDelegae
extension ForYouViewController: ForYouFaceImageTableViewCellDelegae {
    func onFaceImageButton() {
        output.onFaceImageButton()
    }
}

extension ForYouViewController: ForYouTimelineTableViewCellDelegate {
    func saveTimelineCard(id: Int) {
        output.currentSection = .timeline
        output.saveTimelineCard(id: id)
    }
    
    func setTimelineNil() {
        output.setTimelineNil()
        updateTableView(for: .timeline)
    }
    
    func shareTimeline(item: BaseDataSourceItem, type: CardShareType) {
        shareCardContentManager.presentSharingMenu(item: item, type: type)
    }
}

//MARK: -ItemOperationManagerViewProtocol
extension ForYouViewController: ItemOperationManagerViewProtocol {
    func isEqual(object: ItemOperationManagerViewProtocol) -> Bool {
        return self === object
    }
    
    func faceImageRecogChaned(to isAllowed: Bool) {
        if isFIREnabled != isAllowed {
            faceImagePermissionChanged(to: isAllowed)
            tableView.reloadData()
        }
    }
    
    func tabBarDidChange() {
        output.currentSection = nil
    }
    
    func allCardsRemoved(for section: ForYouSections) {
        output.emptyCardData(for: section)
        updateTableView(for: section)
    }
}

//MARK: -ShareCardContentManagerDelegate
extension ForYouViewController: ShareCardContentManagerDelegate {
    func shareOperationStarted() {
        showSpinner()
    }
    
    func shareOperationFinished() {
        hideSpinner()
    }
}
