//
//  SelectionMenuController.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit

enum PhotoEditSaveMenu: Int, CaseIterable {
    case saveAsCopy
    case resetToOriginal
    
    var title: String {
        switch self {
            case .saveAsCopy:
                return TextConstants.photoEditSaveAsCopy
            case .resetToOriginal:
                return TextConstants.photoEditResetToOriginal
            default:
                assertionFailure("Set title for the case")
                return " "
        }
    }
}

final class SelectionMenuController: UIViewController, NibInit {
    
    static func photoEditMenu(onSelect: @escaping ValueHandler<PhotoEditSaveMenu?>) -> SelectionMenuController {
        let items = PhotoEditSaveMenu.allCases.compactMap { $0.title }
        return SelectionMenuController.with(style: .simple, items: items, selectedIndex: nil) { selectedIndex in
            guard let index = selectedIndex, let option = PhotoEditSaveMenu(rawValue: index) else {
                onSelect(nil)
                return
            }
            onSelect(option)
        }
    }
    
    static func with(style: SelectionMenuCell.Style, items: [String], selectedIndex: Int?, handler: @escaping ValueHandler<Int?>) -> SelectionMenuController {
        let controller = SelectionMenuController.initFromNib()
        controller.style = style
        controller.items = items
        controller.selectedIndex = selectedIndex
        controller.handler = handler
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        return controller
    }
    
    @IBOutlet private weak var backgroundView: UIView! {
        willSet {
            newValue.backgroundColor = UIColor(white: 0, alpha: 0.3)
            newValue.alpha = 0
            
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(onViewTap))
            newValue.addGestureRecognizer(recognizer)
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    private var style: SelectionMenuCell.Style = .simple
    private var items = [String]()
    private var selectedIndex: Int?
    private var handler: ValueHandler<Int?>?
    
    private let cellHeight: CGFloat = Device.isIpad ? 55 : 44
    private var tableViewHeight: CGFloat = 0
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: NumericConstants.animationDuration) {
            self.tableViewHeightConstraint.constant = self.tableViewHeight
            self.backgroundView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupTableView() {
        tableViewHeightConstraint.constant = 0
        tableView.register(nibCell: SelectionMenuCell.self)
        tableView.rowHeight = cellHeight
        
        if #available(iOS 11.0, *) {
            let bottomInsets = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            tableViewHeight = CGFloat(items.count) * cellHeight + bottomInsets
            tableView.contentInset.bottom = bottomInsets
        } else {
            tableViewHeight = CGFloat(items.count) * cellHeight
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = ColorConstants.photoEditBackgroundColor
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = tableView.contentSize.height > tableView.frame.height
        
        if let row = selectedIndex {
            tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
        }
    }
    
    @objc private func onViewTap() {
        close(with: selectedIndex)
    }
    
    private func close(with value: Int?) {
        UIView.animate(withDuration: NumericConstants.animationDuration, animations: {
            self.tableViewHeightConstraint.constant = 0
            self.backgroundView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.dismiss(animated: false, completion: {
                self?.handler?(value)
            })
        })
    }
}

//MARK: - UITableViewDataSource

extension SelectionMenuController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: SelectionMenuCell.self, for: indexPath)
        cell.setup(style: style, title: items[indexPath.row], isSelected: selectedIndex == indexPath.row)
        return cell
    }
}

//MARK: - UITableViewDelegate

extension SelectionMenuController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        close(with: indexPath.row)
    }
}
