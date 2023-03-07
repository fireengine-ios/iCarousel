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
        view.isHidden = true
        return view
    }()
    
    private lazy var cancelSelectionButton: UIBarButtonItem = {
        return UIBarButtonItem(title: TextConstants.cancelSelectionButtonTitle,
                               font: .TurkcellSaturaDemFont(size: 19.0),
                               target: self,
                               selector: #selector(onCancelSelectionButton))
    }()
    
    private lazy var more: NavBarWithAction = {
        let view = NavBarWithAction(navItem: NavigationBarList().more) { [weak self] item in
            self?.onMorePressed(item)
        }
        view.navItem.isEnabled = false
        return view
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
    
    var timer: Timer?
    
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // invalidate the timer when the view disappears
        stopTimer()
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
        navBarConfigurator.configure(right: [more], left: [])
        navBarRightItems = navBarConfigurator.rightItems
    }
    
    private func onMorePressed(_ sender: Any) {
        threeDotMenuManager.showActions(sender: sender,
                                        onlyRead: output.onlyRead,
                                        onlyShowAlerts: output.onlyShowAlerts)
    }
    
    @objc private func onCancelSelectionButton(_ sender: Any) {
        stopEditingMode()
    }
    
    private func startEditingMode(at indexPath: IndexPath?) {
        guard !isSelectingMode else {
            return
        }
        
        isSelectingMode = true
        deselectAllCells()
        
        /// Back button case
        displayManager = .selection
        updateNavBarItems()

        isSelectionObject = 0
        updateSelectedItemsCount()
        updateBarsForSelectedObjects()
        
        // BottomSheet height
        tableView.contentInset.bottom = 110
    }
    
    private func stopEditingMode() {
        
        /// Back button case
        displayManager = .initial
        updateNavBarItems()
        
        isSelectingMode = false
        deselectAllCells()
        bottomBarManager.hide()
        bottomBarCard.isHidden = true
        tableView.contentInset.bottom = 0
    }
    
    private func updateBarsForSelectedObjects() {
        bottomBarManager.update(for: !selectedIndexes.isEmpty, isSelectedAll: selectedIndexes.count == output.notificationsCount())
        bottomBarCard.isHidden = false
        bottomBarCard.setCount(with: selectedIndexes.count)
        
        if !isSelectingMode {
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
    
    private func deselectAll() {
        selectedIndexes.forEach { indexPath in
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    private func deleteSelectedCells() {
        let rows = selectedIndexes.map { $0.row }
        output.deleteAllNotification(at: rows)
        tableView.deleteRows(at: selectedIndexes, with: .fade)
        updateSelectedItemsCount()
        updateBarsForSelectedObjects()
    }
    
    private func deleteAllCells() {
        output.deleteAllNotification()
        tableView.deleteRows(at: iterateAllCells(), with: .fade)
        updateSelectedItemsCount()
        updateBarsForSelectedObjects()
    }
    
    private func deleteNotification(row: IndexPath) {
        output.deleteNotification(at: row.row )
        let indexPath = IndexPath(item: row.row , section: 0)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    private func selectAllCells() {
        iterateAllCells().forEach { indexPath in
            tableView.selectOneRow(isSelected: isSelectingMode, indexPath: indexPath)
        }
    }
    
    private func iterateAllCells() -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
}

// MARK: - UIScrollViewDelegate methods
extension NotificationViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // restart the timer when the user scrolls the table view
        
        if !output.onlyRead && !output.onlyShowAlerts,
            output.updatedCellsCount() < output.notificationsCount() {
            restartTimer()
        }
    }
}

// MARK: - Timer methods
extension NotificationViewController {
    private func restartTimer() {
        // I just wanted to make algorith clear, therefore I invoke restartTimer like that
        startTimer()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = Timer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        var timeInterval = TimeInterval(FirebaseRemoteConfig.shared.notificationReadTime)
        if timeInterval == 0 {
            timeInterval = 3
        }
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self,
                                     selector: #selector(updateCells), userInfo: nil, repeats: true)
    }
}

// MARK: NotificationViewInput
extension NotificationViewController: NotificationViewInput {
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func setEmptyView(as hidden: Bool) {
        emptyView.isHidden = hidden
        
        if !output.onlyRead && !output.onlyShowAlerts {
            more.navItem.isEnabled = hidden
        }
    }
    
    func reloadTimer() {
        startTimer()
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
            guard let row = tableView.indexPath(for: cell) else { return }
            self?.deleteNotification(row: row)
        }
        return cell
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
    
    @objc func updateCells() {
        // stop the timer if there are no more cells to update
        if output.updatedCellsCount() == output.notificationsCount() {
            stopTimer()
        }
        
        // get the currently visible cell indexes
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows?.compactMap({$0.row}) else { return }
        
        let differenceCells = output.updatedCellsDiff(visibleIndexPaths)
        
        differenceCells.forEach { el in
            let indexPath = IndexPath(row: el, section: 0)
            
            guard let cell = tableView.cellForRow(at: indexPath) as? NotificationTableViewCell else {
                return
            }
            let model = output.getNotification(at: indexPath.row)
            model.status = "READ"
            cell.updateStatus(model: model)
            cell.updateSelection(isSelectionMode: isSelectingMode, animated: false)
            output.read(with: model.communicationNotificationId?.description ?? "")
            
            output.insertUpdatedCells(member: el)
        }
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
    
    func delete(all: Bool) {
        if all {
            deleteAllCells()
        } else {
            deleteSelectedCells()
        }
    }
    
    func selectModeSelected() {
        startEditingMode(at: nil)
    }
    
    func selectAllModeSelected() {
        selectAllCells()
    }
    
    func showOnly(withType type: ElementTypes) {
        switch type {
        case .onlyUnreadOn:
            output.onlyRead.toggle()
            output.onlyShowAlerts ? output.showOnlyWarning() : output.showAll()
            
            if !output.onlyRead && !output.onlyShowAlerts {
                startTimer()
            }
            
        case .onlyUnreadOff:
            output.onlyRead.toggle()
            output.onlyShowAlerts ? output.showOnlyWarningAndUnread() : output.showOnlyUnread()
            stopTimer()
            
        case .onlyShowAlertsOn:
            output.onlyShowAlerts.toggle()
            output.onlyRead ? output.showOnlyUnread() : output.showAll()
            
            if !output.onlyRead && !output.onlyShowAlerts {
                startTimer()
            }
            
        case .onlyShowAlertsOff:
            output.onlyShowAlerts.toggle()
            output.onlyRead ? output.showOnlyWarningAndUnread() : output.showOnlyWarning()
            stopTimer()
            
        default:
            break
        }
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
