//
//  GridListTopBarSortingTableView.swift
//  Depo
//
//  Created by Aleksandr on 9/8/17.
//  Copyright © 2017 com.igones. All rights reserved.
//

protocol GridListTopBarSortingTableViewDelegate: class {
    func gridListTopBarSortingTableView(_ gridListTopBarSortingTableView: GridListTopBarSortingTableView, didSelectItemAtIndex index: IndexPath)
}

class GridListTopBarSortingTableView: UITableViewController {
    
    private var currentTitles: [String]?
    private var currentlySelectedIndex: Int?
    
    weak var actionDelegate: GridListTopBarSortingTableViewDelegate?
    
    let defaultCellHeight: CGFloat = 43.7
    
    let gridListTableCellNibName = "GridListTopBarSortingTableCell"
    let gridListTableCellReuseIdentifier = "GridListTopBarSortingTableCell"
    let separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialState()
    }
    
    private func setupInitialState() {
        tableView.register(UINib(nibName: gridListTableCellNibName, bundle: nil),
                           forCellReuseIdentifier: gridListTableCellReuseIdentifier)
        tableView.isScrollEnabled = false
        tableView.separatorInset = separatorInset
    }
    
    func setup(withTitles titles: [String], selectedIndex: Int) {
        currentTitles = titles
        currentlySelectedIndex = selectedIndex
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return defaultCellHeight
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTitles?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let simpleCell = tableView.dequeueReusableCell(withIdentifier: "GridListTopBarSortingTableCell",
                                                       for: indexPath)
        var isCellSelected: Bool = false
        
        if let selectedIndex = currentlySelectedIndex, selectedIndex == indexPath.row {
            isCellSelected = true
        }
        if let simpleGridListCellUnwrapped = simpleCell as? GridListTopBarSortingTableCell,
            let unwrapedTitles = currentTitles {
            let titleText = unwrapedTitles[indexPath.row]
            simpleGridListCellUnwrapped.setup(withText: titleText, selected: isCellSelected)
        }
 
        return simpleCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) as? GridListTopBarSortingTableCell else {
            return
        }
        selectedCell.isSelected = false
        unselectAllCells(table: tableView)
        
        selectedCell.changeState(selected: true)
        
        actionDelegate?.gridListTopBarSortingTableView(self, didSelectItemAtIndex: indexPath)
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
