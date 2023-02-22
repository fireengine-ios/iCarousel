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
    
    private lazy var tableView: QuickSelectTableView = {
        let view = QuickSelectTableView()
        view.register(NotificationTableViewCell.self, forCellReuseIdentifier: "NotificationTableViewCell")
        view.separatorStyle = .none
        view.longPressDelegate = self
        view.allowsMultipleSelectionDuringEditing = true
        return view
    }()
    
    private lazy var bottomBarCard: SimpleBottomBarCard = {
        let view = SimpleBottomBarCard()
        view.delegate = self
        return view
    }()
    
    private lazy var emptyView: NotificationEmptyView = {
        let view = NotificationEmptyView()
        return view
    }()
    
    private lazy var cancelSelectionButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onCancelSelectionButton))
    }()
    
    private lazy var threeDotMenuManager = NotificationThreeDotMenuManager(delegate: self)
    private lazy var bottomBarManager = NotificationBottomBarManager(delegate: self)
    
    private var displayManager: NotificationDisplayConfiguration = .initial
    
    private var navBarConfigurator = NavigationBarConfigurator()
    private var navBarRightItems: [UIBarButtonItem]?
    private var isSelectingMode: Bool = false
    private var isSelectionObject: Int = 0
    private var selectedIndexes: [IndexPath] {
        return tableView.indexPathsForSelectedRows ?? []
    }
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.notificationMenuItem))
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        
        output.viewIsReady()
        
        bottomBarManager.setup()
        displayManager = .initial
        configureNavBarActions()
        updateNavBarItems()
        bottomBarCard.setLayout(with: view)
        emptyView.setLayout(with: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        output.viewWillAppear()
        bottomBarManager.editingTabBar?.view.layoutIfNeeded()
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
        stopEditingMode()
    }
    
    private func startEditingMode(at indexPath: IndexPath?) {
        guard !isSelectingMode else {
            return
        }
        
        /// Back button case
        displayManager = .selection
        updateNavBarItems()
        
        isSelectingMode = true
        deselectAllCells()

        isSelectionObject = 0
        updateSelectedItemsCount()
        updateBarsForSelectedObjects()
    }
    
    private func stopEditingMode() {
        
        /// Back button case
        displayManager = .initial
        updateNavBarItems()
        
        isSelectingMode = false
        deselectAllCells()
        bottomBarManager.hide()
        bottomBarCard.isHidden = true
    }
    
    private func updateBarsForSelectedObjects() {
        let rows = selectedIndexes.map { $0.row }
        bottomBarManager.update(for: !rows.isEmpty)
        bottomBarCard.isHidden = false
        bottomBarCard.setCount(with: rows.count)
        
        if selectedIndexes.count == 0 {
            bottomBarManager.hide()
            bottomBarCard.isHidden = true
        } else {
            bottomBarManager.show()
        }
    }
    
    private func updateSelectedItemsCount() {
        let selectedIndexesCount = selectedIndexes.count
        isSelectionObject += 1
        //setTitle(withString: "\(selectedIndexesCount) \(TextConstants.accessibilitySelected)")
        if selectedIndexesCount == 0 && isSelectionObject > 1 {
            stopEditingMode()
            isSelectionObject = 0
        }
    }
    
    private func deselectAllCells() {
        deselectAll()
        tableView.visibleCells.forEach { cell in
            (cell as? NotificationTableViewCell)?.updateSelection(isSelectionMode: isSelectingMode, animated: false)
        }
    }
    
    func deselectAll() {
        selectedIndexes.forEach { indexPath in
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    private func selectAllCells() {
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                tableView.selectOneRow(isSelected: isSelectingMode, indexPath: indexPath)
            }
        }
    }
}

// MARK: NotificationViewInput
extension NotificationViewController: NotificationViewInput {
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func setEmptyView(as hidden: Bool) {
        emptyView.isHidden = hidden
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
            self?.deleteNotification(tableView: tableView, cell: cell)
        }
        return cell
    }
    
    private func deleteNotification(tableView: UITableView, cell: NotificationTableViewCell) {
        let row = tableView.indexPath(for: cell)
        output.deleteNotification(at: row?.row ?? 0)
        let indexPath = IndexPath(item: row?.row ?? 0, section: 0)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
}

// MARK: - UITableViewDelegate
extension NotificationViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? NotificationTableViewCell else {
            return
        }
        
        cell.updateSelection(isSelectionMode: isSelectingMode, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NotificationTableViewCell else {
            return
        }
        if isSelectingMode {
            updateSelection(cell: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NotificationTableViewCell else {
            return
        }
        
        if isSelectingMode {
            updateSelection(cell: cell)
        }
    }
    
    private func updateSelection(cell: NotificationTableViewCell) {
        cell.updateSelection(isSelectionMode: isSelectingMode, animated: false)
        updateSelectedItemsCount()
        
        ///fix bottom bar update scrolling freeze on dragging
        guard !tableView.isQuickSelecting else {
            return
        }

        updateBarsForSelectedObjects()
    }
}

extension NotificationViewController: QuickSelectTableViewDelegate {
    func didLongPress(at indexPath: IndexPath?) {
        if !isSelectingMode {
            startEditingMode(at: indexPath)
        }
    }
    
    func didEndLongPress(at indexPath: IndexPath?) {
        if isSelectingMode {
            self.updateSelectedItemsCount()
            self.updateBarsForSelectedObjects()
        }
    }
}

extension NotificationViewController: SimpleBottomBarCardDelegate {
    func cancelButtonAction() {
        stopEditingMode()
    }
}

extension NotificationViewController: BaseItemInputPassingProtocol {
    func operationFinished(withType type: ElementTypes, response: Any?) {
        
    }
    
    func operationFailed(withType type: ElementTypes) {
        
    }
    
    func stopModeSelected() {
        stopEditingMode()
    }
    
    func deleteAll() {
        print("yilmaz edis: Delete All")
    }
    
    func selectModeSelected() {
        startEditingMode(at: nil)
    }
    
    func selectAllModeSelected() {
        selectAllCells()
    }
    
    func deSelectAll() {
        
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
        selectedItemsCallback([])
    }
}
