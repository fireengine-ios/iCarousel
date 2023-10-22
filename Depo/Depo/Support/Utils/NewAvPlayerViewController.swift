//
//  NewAvPlayerViewController.swift
//  Depo
//
//  Created by Ozan Salman on 11.10.2023.
//  Copyright © 2023 LifeTech. All rights reserved.
//

import AVKit

final class NewAvPlayerViewController: AVPlayerViewController {
    
    private lazy var more = UIBarButtonItem(image: Image.iconKebabBorder.image,
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(onMorePressed))
    
    private lazy var back = UIBarButtonItem(image: NavigationBarImage.back.image,
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(onBackPressed))
    private var navBarRightItems: [UIBarButtonItem]?
    private var navBarLeftItems: [UIBarButtonItem]?
    private var timelineResponse: TimelineResponse?
    private var navBarConfigurator = NavigationBarConfigurator()
    private lazy var threeDotMenuManager = PlayerThreeDotMenuManager(delegate: self)
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    init(item: TimelineResponse?) {
        self.timelineResponse = item
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = AppColor.darkBlue.color
        configureNavBarActions()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        view.subviews.first?.subviews[1].subviews[0].isHidden = true //x button hide
        view.subviews.first?.subviews[1].subviews[5].isHidden = true //sound button hide
    }
    
    private func configureNavBarActions() {
        navigationItem.rightBarButtonItem = more
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        let navbarTitle = UILabel()
        navbarTitle.textColor = .white
        navbarTitle.text = localized(.timelineHeader)
        navbarTitle.font = .appFont(.medium, size: 16)
        navbarTitle.minimumScaleFactor = 0.5
        navbarTitle.adjustsFontSizeToFitWidth = true
        navigationItem.titleView = navbarTitle
    }
    
    @objc private func onMorePressed(_ sender: Any) {
        //threeDotMenuManager.showActions(sender: sender)
        //threeDotMenuManager.showActions(sender: sender, items: <#T##[WrapData]#>)
        let item = WrapData(timelineResponse: timelineResponse!)
        threeDotMenuManager.showActions(sender: sender, item: item)
        
    }
    
    @objc private func onBackPressed() {
        dismiss(animated: false)
    }
}

extension NewAvPlayerViewController: BaseItemInputPassingProtocol {
    func operationFinished(withType type: ElementTypes, response: Any?) {
        print("aaaaaaaaa")
    }
    
    func operationFailed(withType type: ElementTypes) {
        print("aaaaaaaaa")
    }
    
    func selectModeSelected() {
        print("aaaaaaaaa")
    }
    
    func selectAllModeSelected() {
        print("aaaaaaaaa")
    }
    
    func deSelectAll() {
        print("aaaaaaaaa")
    }
    
    func stopModeSelected() {
        print("aaaaaaaaa")
    }
    
    func printSelected() {
        print("aaaaaaaaa")
    }
    
    func changeCover() {
        print("aaaaaaaaa")
    }
    
    func changePeopleThumbnail() {
        print("aaaaaaaaa")
    }
    
    func openInstaPick() {
        print("aaaaaaaaa")
    }
    
    func getSelectedItems(selectedItemsCallback: @escaping BaseDataSourceItems) {
        let item = WrapData(timelineResponse: timelineResponse!)
        selectedItemsCallback([item])
    }
    
    
}
