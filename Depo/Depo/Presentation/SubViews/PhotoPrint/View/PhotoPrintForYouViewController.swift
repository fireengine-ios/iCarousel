//
//  PhotoPrintForYouViewController.swift
//  Depo
//
//  Created by Ozan Salman on 26.09.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import Foundation

final class PhotoPrintForYouViewController: BaseViewController {
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(PhotoPrintSeeAllTableViewCell.self, forCellReuseIdentifier: "PhotoPrintSeeAllTableViewCell")
        view.backgroundColor = AppColor.background.color
        view.separatorStyle = .none
        return view
    }()
    
    private lazy var plusButton: NavBarWithAction = {
        let view = NavBarWithAction(navItem: NavigationBarList().plus) { [weak self] item in
            self?.onPlusPressed(item)
        }
        return view
    }()
 
    private var photoPrintData: [GetOrderResponse]?
    private var navBarRightItems: [UIBarButtonItem]?
    private var navBarConfigurator = NavigationBarConfigurator()
    private lazy var service = ForYouService()
    
    init(item: [GetOrderResponse] = []) {
        photoPrintData = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitle(withString: localized(.printedPhotoCardTitle))
        view.backgroundColor = AppColor.background.color
        
        configureNavBarActions()
        configureTableView()
        showSpinner()
        
        if photoPrintData?.count == 0 {
            getData()
        } else {
            tableView.reloadData()
            hideSpinner()
        }
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
    
    private func configureNavBarActions() {
        navBarConfigurator.configure(right: [plusButton], left: [])
        navBarRightItems = navBarConfigurator.rightItems
        navigationItem.rightBarButtonItems = navBarRightItems
    }
    
    private func onPlusPressed(_ sender: Any) {
        let router = RouterVC()
        let vc = router.photoPrintSelectPhotos(popupShowing: true)
        router.pushViewController(viewController: vc, animated: false)
    }
    
}

extension PhotoPrintForYouViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoPrintData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoPrintSeeAllTableViewCell", for: indexPath) as? PhotoPrintSeeAllTableViewCell else {
            return UITableViewCell()
        }
        
        cell.configure(item: photoPrintData?[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PhotoPrintForYouViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PhotoPrintStatusPopup.with(photoPrintData: (photoPrintData?[indexPath.row])!)
        vc.open()
    }
}

extension PhotoPrintForYouViewController {
    private func getData() {
        service.forYouPrintedPhotos() { [weak self] result in
            switch result {
            case .success(let response):
                self?.hideSpinner()
                self?.photoPrintData = response
                self?.tableView.reloadData()
            case .failed(let error):
                self?.hideSpinner()
                print("ForYou Error getPrintedPhotos: \(error.description)-\(String(describing: error.description))")
                break
            }
        }
    }
}
