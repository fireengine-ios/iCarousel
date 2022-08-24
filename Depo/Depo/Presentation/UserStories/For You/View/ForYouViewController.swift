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
    lazy var isFIREnabled: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: -IBOutlet
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: -Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("ForYou viewDidLoad")
        
        configureUI()
        configureTableView()
        output.checkFIRisAllowed()
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
        cell.configure(with: forYouEnum[indexPath.row])
        cell.delegate = self
        return cell
    }
}

//MARK: -UITableViewDelegate
extension ForYouViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !isFIREnabled && indexPath.row == 0 {
            return 224
        }

        if forYouEnum[indexPath.row] == .people {
            return 150
        }
        
        return 190
    }
}

//MARK: -ForYouTableViewCellDelegate
extension ForYouViewController: ForYouTableViewCellDelegate {
    func onSeeAllButton(for view: ForYouViewEnum) {
        output.onSeeAllButton(for: view)
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
    
    func navigateToCreate(for view: ForYouViewEnum) {
        output.navigateToCreate(for: view)
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
        }
    }
}
