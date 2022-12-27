//
//  GridListTopBarSortingTableView.swift
//  Depo
//
//  Created by Aleksandr on 9/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

import UIKit

protocol GridListTopBarSortingTableViewDelegate: AnyObject {
    func gridListTopBarSortingTableView(_ gridListTopBarSortingTableView: GridListTopBarSortingTableView, didSelectItemAtIndex index: IndexPath)
}

class GridListTopBarSortingTableView: UIViewController {
    
    private var currentTitles: [String]?
    private var sortImages: [Image]?
    private var currentlySelectedIndex: Int?
    
    weak var actionDelegate: GridListTopBarSortingTableViewDelegate?
    
    let defaultCellHeight: CGFloat = 60
    
    let gridListTableCellNibName = "GridListTopBarSortingTableCell"
    let gridListTableCellReuseIdentifier = "GridListTopBarSortingTableCell"
    let separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
    
    lazy var tableView: ResizableTableView = {
        let tv = ResizableTableView(frame: .zero, style: .plain)
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
        
    }
    
    private func setupInitialState() {
        tableView.register(UINib(nibName: gridListTableCellNibName, bundle: nil),
                           forCellReuseIdentifier: gridListTableCellReuseIdentifier)
        tableView.separatorInset = separatorInset
        view.addSubview(tableView)
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func setup(withTitles titles: [String], images: [Image], selectedIndex: Int) {
        currentTitles = titles
        currentlySelectedIndex = selectedIndex
        sortImages = images
        tableView.reloadData()
    }
    
    private func unselectAllCells(table: UITableView) {
        table.visibleCells.forEach({ cell in
            guard let gridListCell = cell as? GridListTopBarSortingTableCell else {
                return
            }
            gridListCell.changeState(selected: false)
        })
    }
}

extension GridListTopBarSortingTableView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return defaultCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTitles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let simpleCell = tableView.dequeueReusableCell(withIdentifier: "GridListTopBarSortingTableCell",
                                                       for: indexPath)
        var isCellSelected: Bool = false
        
        if let selectedIndex = currentlySelectedIndex, selectedIndex == indexPath.row {
            isCellSelected = true
        }
        if let simpleGridListCellUnwrapped = simpleCell as? GridListTopBarSortingTableCell,
            let unwrapedTitles = currentTitles, let images = sortImages {
            let titleText = unwrapedTitles[indexPath.row]
            let image = images[indexPath.row]
            simpleGridListCellUnwrapped.setup(withText: titleText, selected: isCellSelected, icon: image)
        }
 
        return simpleCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? GridListTopBarSortingTableCell else {
            return
        }
        selectedCell.isSelected = false
        unselectAllCells(table: tableView)
        
        selectedCell.changeState(selected: true)
        
        actionDelegate?.gridListTopBarSortingTableView(self, didSelectItemAtIndex: indexPath)
    }
}
