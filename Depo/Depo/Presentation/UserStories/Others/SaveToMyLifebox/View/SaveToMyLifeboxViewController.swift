//
//  SaveToMyLifeboxViewController.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class SaveToMyLifeboxViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    var output: SaveToMyLifeboxViewOutput!
    var mainTitle: String?
    private let actionView = SaveToMyLifeboxActionView.initFromNib()
    private var dataSource: [WrapData] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureUI()
        output.viewIsReady()
        actionView.delegate = self
    }
    
    private func setupTableView() {
        tableView.register(nibCell: SaveToMyLifeboxTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configureUI() {
        self.setTitle(withString: self.mainTitle ?? "")

        view.addSubview(actionView)
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).activate()
        actionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        actionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        actionView.heightAnchor.constraint(equalToConstant: 110).activate()
    }
}

extension SaveToMyLifeboxViewController: SaveToMyLifeboxViewInput {
    func sharedItemsDidGet(items: [SharedFileInfo]) {
        
        for item in items {
            let wrapData = WrapData(privateShareFileInfo: item)
            dataSource.append(wrapData)
        }
    }
}

extension SaveToMyLifeboxViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(reusable: SaveToMyLifeboxTableViewCell.self, for: indexPath)
        let item = dataSource[indexPath.row]
        cell.configure(With: item)
        return cell
    }
}


extension SaveToMyLifeboxViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 62
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        if item.fileType == .folder {
            output.onSelect(item: item)
        }
    }
}

extension SaveToMyLifeboxViewController: SaveToMyLifeboxActionViewDelegate {
    func downloadButtonDidTapped() {
        return
    }
    
    func saveToMyLifeboxButtonDidTapped() {
        output.saveToMyLifeboxSaveRoot()
    }
}
