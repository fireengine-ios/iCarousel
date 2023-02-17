//
//  NotificationViewController.swift
//  Depo
//
//  Created by yilmaz edis on 9.02.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import UIKit

enum NotificationDisplayConfiguration {
    case initial
    case empty
    case selection
}

final class NotificationViewController: BaseViewController {
    var output: NotificationViewOutput!
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(NotificationTableViewCell.self, forCellReuseIdentifier: "NotificationTableViewCell")
        view.separatorStyle = .none
        return view
    }()
    
    private lazy var cancelSelectionButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onCancelSelectionButton))
    }()
    
    private lazy var threeDotMenuManager = NotificationThreeDotMenuManager(delegate: self)
    
    private var displayManager: NotificationDisplayConfiguration = .initial
    
    private var navBarConfigurator = NavigationBarConfigurator()
    private var navBarRightItems: [UIBarButtonItem]?
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.notificationMenuItem))
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        
        output.viewIsReady()
        
        displayManager = .initial
        configureNavBarActions()
        updateNavBarItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewWillAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func updateNavBarItems() {
        switch displayManager {
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
    
    private func configureNavBarActions() {
        let more = NavBarWithAction(navItem: NavigationBarList().more) { [weak self] item in
            self?.onMorePressed(item)
        }
        let rightActions: [NavBarWithAction] = [more]
        navBarConfigurator.configure(right: rightActions, left: [])
        navBarRightItems = navBarConfigurator.rightItems
    }
    
    private func onMorePressed(_ sender: Any) {

        threeDotMenuManager.showActions(
            sender: sender
        )
    }
    
    @objc private func onCancelSelectionButton(_ sender: Any) {
        //stopSelection()
    }
}

// MARK: NotificationViewInput
extension NotificationViewController: NotificationViewInput {
    func reloadTableView() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension NotificationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.notificationsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(model: output.getNotification(at: indexPath.row), readMode: true)
        cell.selectionStyle = .none
        cell.deleteHandler = { [weak self] in
            let row = tableView.indexPath(for: cell)
            self?.output.deleteNotification(at: row?.row ?? 0)
            let indexPath = IndexPath(item: row?.row ?? 0, section: 0)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotificationViewController: UITableViewDelegate {}

extension NotificationViewController: BaseItemInputPassingProtocol {
    func operationFinished(withType type: ElementTypes, response: Any?) {
        
    }
    
    func operationFailed(withType type: ElementTypes) {
        
    }
    
    func selectModeSelected() {
        
    }
    
    func selectAllModeSelected() {
        
    }
    
    func deSelectAll() {
        
    }
    
    func stopModeSelected() {
        
    }
    
    func printSelected() {
        
    }
    
    func changeCover() {
        
    }
    
    func changePeopleThumbnail() {
        
    }
    
    func openInstaPick() {
    
    }
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        
    }
    
    
}
