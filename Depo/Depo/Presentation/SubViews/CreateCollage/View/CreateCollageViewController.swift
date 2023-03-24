//
//  CreateCollageViewController.swift
//  Depo
//
//  Created by Ozan Salman on 2.03.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation
import UIKit

final class CreateCollageViewController: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(CreateCollageTableViewCell.self, forCellReuseIdentifier: "CreateCollageTableViewCell")
        view.backgroundColor = AppColor.background.color
        view.separatorStyle = .none
        return view
    }()
    
    var output: CreateCollageViewOutput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        debugLog("CreateCollage viewDidLoad")
        
        setTitle(withString: "Create Collage")
        view.backgroundColor = ColorConstants.fileGreedCellColorSecondary
        configureTableView()
        output.viewIsReady()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func getSectionByKey(key: Int) -> CollageTemplateSections {
        var section: CollageTemplateSections?
        if key == 2 {
            section = .dual
        } else if key == 3 {
            section = .triple
        } else if key == 4 {
            section = .quad
        } else {
            section = .multiple
        }
        return section ?? .all
    }
}

extension CreateCollageViewController: CreateCollageViewInput {
    func didFinishedAllRequests() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension CreateCollageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return output.getSectionsCountAndName().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CreateCollageTableViewCell", for: indexPath) as? CreateCollageTableViewCell else {
            return UITableViewCell()
        }
        
        let key = output.getSectionsCountAndName()[indexPath.row]
        cell.configure(model: output.getSectionsCollageTemplateData(shapeCount: key), section: getSectionByKey(key: key))
        cell.delegate = self
        cell.selectionStyle = .none
        cell.backgroundColor = AppColor.background.color
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CreateCollageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? CreateCollageTableViewCell else {
            return
        }
    }
}

extension CreateCollageViewController: CreateCollageTableViewCellDelegate {
    func onSeeAllButton(for section: CollageTemplateSections) {
        output.onSeeAllButton(for: section)
    }
    
    func naviateToCollageTemplateDetail(collageTemplate: CollageTemplateElement) {
        output.naviateToCollageTemplateDetail(collageTemplate: collageTemplate)
    }
}


extension CreateCollageViewController: ShareCardContentManagerDelegate {
    func shareOperationStarted() {
        showSpinner()
    }
    
    func shareOperationFinished() {
        hideSpinner()
    }
}
