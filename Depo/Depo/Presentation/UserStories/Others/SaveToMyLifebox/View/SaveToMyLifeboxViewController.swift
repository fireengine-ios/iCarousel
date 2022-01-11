//
//  SaveToMyLifeboxViewController.swift
//  Depo
//
//  Created by Burak Donat on 8.01.2022.
//  Copyright © 2022 LifeTech. All rights reserved.
//

import UIKit

class SaveToMyLifeboxViewController: ViewController, ControlTabBarProtocol {
    
    //MARK: -IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: -Properties
    var output: SaveToMyLifeboxViewOutput!
    var mainTitle: String?
    private let actionView = SaveToMyLifeboxActionView.initFromNib()
    private var page: Int = 0
    private var isLastPage: Bool = false
    private var isLoading: Bool = false

    private var dataSource: [WrapData] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    //MARK: -Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        configureUI()
        output.viewIsReady(at: page)
        isLoading = true
        actionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideTabBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: -Helpers
    private func setupTableView() {
        tableView.register(nibCell: SaveToMyLifeboxTableViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset.bottom = actionView.frame.size.height
    }
    
    private func configureUI() {
        self.setTitle(withString: self.mainTitle ?? "")
        navigationBarWithGradientStyle(isHidden: false, hideLogo: true)

        view.addSubview(actionView)
        actionView.translatesAutoresizingMaskIntoConstraints = false
        actionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).activate()
        actionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).activate()
        actionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).activate()
        actionView.heightAnchor.constraint(equalToConstant: NumericConstants.saveToMyLifeboxActionViewHeight).activate()
    }
}

//MARK: -SaveToMyLifeboxViewInput
extension SaveToMyLifeboxViewController: SaveToMyLifeboxViewInput {
    func didGetSharedItems(items: [SharedFileInfo]) {
        isLoading = false
        for item in items {
            let wrapData = WrapData(privateShareFileInfo: item)
            dataSource.append(wrapData)
        }
    }
    
    func operationDidFinish() {
        isLastPage = true
    }
}

//MARK: -UITableViewDataSource
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

//MARK: -UITableViewDelegate
extension SaveToMyLifeboxViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NumericConstants.saveToMyLifeboxCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource[indexPath.row]
        if item.fileType == .folder {
            output.onSelect(item: item)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = tableView else { return }
        guard scrollView.contentOffset.y > 0 else { return }
        if scrollView.contentOffset.y > (tableView.contentSize.height - tableView.frame.size.height) {
            if !isLoading && !isLastPage {
                page += 1
                output.viewIsReady(at: page)
                isLoading = true
            }
        }
    }
}

//MARK: -SaveToMyLifeboxActionViewDelegate
extension SaveToMyLifeboxViewController: SaveToMyLifeboxActionViewDelegate {
    func downloadButtonDidTapped() {
        return
    }
    
    func saveToMyLifeboxButtonDidTapped() {
        output.saveToMyLifeboxSaveRoot()
    }
}
