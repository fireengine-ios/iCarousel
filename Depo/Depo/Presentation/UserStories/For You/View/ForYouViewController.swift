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
            tableView.reloadData()
        }
    }
    
    //MARK: -IBOutlet
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: -Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("ForYou viewDidLoad")
        
        navigationBarHidden = true
        needToShowTabBar = true
        setDefaultNavigationHeaderActions()
        headerContainingViewController?.isHeaderBehindContent = false
        
        configureTableView()
        output.checkFIRisAllowed()
    }
    
    //MARK: -Helpers
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(nibCell: ForYouTableViewCell.self)
        tableView.register(nibCell: ForYouFaceImageTableViewCell.self)
    }
}

//MARK: -ForYouViewInput
extension ForYouViewController: ForYouViewInput {
    func getFIRResponse(isAllowed: Bool) {
        forYouEnum = ForYouViewEnum.allCases
        
        if isAllowed {
            forYouEnum.remove(.faceImage)
        } else {
            forYouEnum.remove(.people)
            forYouEnum.remove(.things)
        }
        
        isFIREnabled = isAllowed
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
        if forYouEnum[indexPath.row] == .people {
            return 150
        } else if forYouEnum[indexPath.row] == .faceImage {
            return 224
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
