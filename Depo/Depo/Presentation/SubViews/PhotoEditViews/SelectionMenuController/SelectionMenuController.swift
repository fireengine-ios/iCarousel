//
//  SelectionMenuController.swift
//  Depo
//
//  Created by Andrei Novikau on 7/30/20.
//  Copyright © 2020 LifeTech. All rights reserved.
//

import UIKit


final class SelectionMenuController: UIViewController, NibInit {
    
    static func with(style: SelectionMenuCell.Style, items: [String], selectedIndex: Int?, handler: @escaping ValueHandler<Int?>) -> SelectionMenuController {
        let controller = SelectionMenuController.initFromNib()
        controller.style = style
        controller.items = items
        controller.selectedIndex = selectedIndex
        controller.handler = handler
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .coverVertical
        
        return controller
    }
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var tableViewHeight: NSLayoutConstraint!
    
    private var style: SelectionMenuCell.Style = .simple
    private var items = [String]()
    private var selectedIndex: Int?
    private var handler: ValueHandler<Int?>?
    
    private let cellHeight: CGFloat = 44
    
    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        setupBackView()
        setupTableView()
    }

    private func setupBackView() {
        let backView = UIView(frame: view.bounds)
        backView.backgroundColor = .clear
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(onViewTap))
        backView.addGestureRecognizer(recognizer)
        
        view.addSubview(backView)
        view.sendSubview(toBack: backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        backView.pinToSuperviewEdges()
    }
    
    private func setupTableView() {
        tableView.register(nibCell: SelectionMenuCell.self)
        tableView.rowHeight = cellHeight
        
        if #available(iOS 11.0, *) {
            let bottomInsets = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            tableViewHeight.constant = CGFloat(items.count) * cellHeight + bottomInsets
            tableView.contentInset.bottom = bottomInsets
        } else {
            tableViewHeight.constant = CGFloat(items.count) * cellHeight
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = ColorConstants.filterBackColor
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = tableView.contentSize.height > tableView.frame.height
    }
    
    @objc private func onViewTap() {
        close(with: selectedIndex)
    }
    
    private func close(with value: Int?) {
        dismiss(animated: true) { [weak self] in
            self?.handler?(value)
        }
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
        
        if style == .simple {
            close(with: indexPath.row)
        } else {
            if let selectedIndex = selectedIndex, let cell = tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? SelectionMenuCell {
                cell.setSeleted(false)
            }
            
            selectedIndex = indexPath.row
            
            if let cell = tableView.cellForRow(at: indexPath) as? SelectionMenuCell {
                cell.setSeleted(true)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
