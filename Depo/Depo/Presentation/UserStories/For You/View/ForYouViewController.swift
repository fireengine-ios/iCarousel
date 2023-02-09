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
    
    override func viewDidAppear(_ animated: Bool) {
        output.getUpdateData(for: .hidden)
        output.getUpdateData(for: .favorites)
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentSection = output.currentSection else { return }
        output.getUpdateData(for: currentSection)
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
        guard let currentSection = output.currentSection else { return }
        //updateTableView(for: currentSection) // Satır çalışıtrsa kaydedilen kartın thumbnail ini siliyor. Update e gerek yok.
    }
    
    func saveCardFailed(section: ForYouSections) {
        updateTableView(for: section)
    }
    
    func saveCardSuccess(section: ForYouSections) {
        output.getUpdateData(for: section)
    }
}

//MARK: -UITableViewDataSource
extension ForYouViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forYouSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isFIREnabled && indexPath.row == 0 {
            let cell = tableView.dequeue(reusable: ForYouFaceImageTableViewCell.self, for: indexPath)
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeue(reusable: ForYouTableViewCell.self, for: indexPath)
        let model = output.getModel(for: forYouSections[indexPath.row])
        cell.configure(with: model, currentView: forYouSections[indexPath.row])
        cell.delegate = self
        return cell
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
