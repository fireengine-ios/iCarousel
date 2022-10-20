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
    lazy var forYouEnum: [ForYouViewEnum] = []
    lazy var isFIREnabled: Bool = false
    
    //MARK: -IBOutlet
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: -Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("ForYou viewDidLoad")
        
        configureUI()
        configureTableView()
        output.checkFIRisAllowed()
        output.viewIsReady()
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
        forYouEnum = ForYouViewEnum.allCases

        if !isAllowed {
            forYouEnum.remove(.people)
            forYouEnum.remove(.things)
        } else {
            forYouEnum.remove(.faceImage)
        }
        
        isFIREnabled = isAllowed
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
}

//MARK: -UITableViewDataSource
extension ForYouViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forYouEnum.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isFIREnabled && indexPath.row == 0 {
            let cell = tableView.dequeue(reusable: ForYouFaceImageTableViewCell.self, for: indexPath)
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeue(reusable: ForYouTableViewCell.self, for: indexPath)
        let model = output.getModel(for: forYouEnum[indexPath.row])
        cell.configure(with: model, currentView: forYouEnum[indexPath.row])
        cell.delegate = self
        return cell
    }
}

//MARK: -UITableViewDelegate
extension ForYouViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(output.getHeightForRow(at: forYouEnum[indexPath.row]))
    }
}

//MARK: -ForYouTableViewCellDelegate
extension ForYouViewController: ForYouTableViewCellDelegate {
    func navigateToItemPreview(item: WrapData, items: [WrapData]) {
        output.navigateToItemPreview(item: item, items: items)
    }
    
    func onSeeAllButton(for view: ForYouViewEnum) {
        output.onSeeAllButton(for: view)
    }
    
    func navigateToCreate(for view: ForYouViewEnum) {
        output.navigateToCreate(for: view)
    }
    
    func navigateToItemDetail(item: WrapData, faceImageType: FaceImageType?) {
        output.navigateToItemDetail(item: item, faceImageType: faceImageType)
    }
    
    func naviateToAlbumDetail(album: AlbumItem) {
        output.navigateToAlbumDetail(album: album)
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
}
