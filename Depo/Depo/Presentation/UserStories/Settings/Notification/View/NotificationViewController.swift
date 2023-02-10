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
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(NotificationTableViewCell.self, forCellReuseIdentifier: "NotificationTableViewCell")
        return view
    }()
    
    private lazy var cancelSelectionButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onCancelSelectionButton))
    }()
    
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
//        if !dataSource.isSelectionStateActive {
//            showAlertSheet(with: [.select], sender: sender)
//        }
        
        showAlertSheet(with: [.select], sender: sender)
    }
    
    private func showAlertSheet(with types: [ElementTypes], sender: Any?) {
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        types.forEach { type in
            var action: UIAlertAction?
            switch type {
            case .select:
                action = UIAlertAction(title: TextConstants.actionSheetSelect, style: .default, handler: { _ in
//                    self.dataSource.startSelection()
//                    self.startSelection()
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
        
        actionSheetVC.view.tintColor = AppColor.blackColor.color
        actionSheetVC.popoverPresentationController?.sourceView = view
        
        if let pressedBarButton = sender as? UIButton {
            var sourceRectFrame = pressedBarButton.convert(pressedBarButton.frame, to: view)
            if sourceRectFrame.origin.x > view.bounds.width {
                sourceRectFrame = CGRect(origin: CGPoint(x: pressedBarButton.frame.origin.x, y: pressedBarButton.frame.origin.y + 20), size: pressedBarButton.frame.size)
            }
            actionSheetVC.popoverPresentationController?.sourceRect = sourceRectFrame
        } else if let item = sender as? UIBarButtonItem {
            actionSheetVC.popoverPresentationController?.barButtonItem = item
            actionSheetVC.popoverPresentationController?.permittedArrowDirections = .up
        }
        present(actionSheetVC, animated: true)
    }
    
    @objc private func onCancelSelectionButton(_ sender: Any) {
        //stopSelection()
    }
}

// MARK: NotificationViewInput
extension NotificationViewController: NotificationViewInput {

}

// MARK: - UITableViewDataSource
extension NotificationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as? NotificationTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(model: NotificationModel(title: "yilmaz", description: "edis"))
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension NotificationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
