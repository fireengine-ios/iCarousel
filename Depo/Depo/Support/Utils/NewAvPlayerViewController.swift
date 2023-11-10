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
    private var item: WrapData?
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
        showSpinner()
        configureNavBarActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if view.subviews.first?.subviews.count ?? 0 > 1 {
            if view.subviews.first?.subviews[1].subviews.count ?? 0 > 4 {
                view.subviews.first?.subviews[1].subviews[0].isHidden = true //x button hide
                view.subviews.first?.subviews[1].subviews[5].isHidden = true //sound button hide
                view.backgroundColor = UIColor.black.withAlphaComponent(0)
            }
        }
        addViewsToVideo()
        hideSpinner()
    }
    
    private func addViewsToVideo() {
        let width = view.frame.width
        let height = view.frame.height
        let viewTop = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height / 2))
        let viewBottom = UIView(frame: CGRect(x: 0, y: height / 2, width: width, height: height / 2))
        viewTop.backgroundColor = AppColor.timelineTop.color
        viewBottom.backgroundColor = AppColor.timelineBottom.color
        view.addSubview(viewTop)
        view.addSubview(viewBottom)
        view.sendSubviewToBack(viewTop)
        view.sendSubviewToBack(viewBottom)
    }
    
    private func configureNavBarActions() {
        navigationItem.rightBarButtonItem = more
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        let navbarTitle = UILabel()
        navbarTitle.textColor = .white
        navbarTitle.text = String(format: localized(.timelineHeader), Int(Date().getYear())) 
        navbarTitle.font = .appFont(.medium, size: 16)
        navbarTitle.minimumScaleFactor = 0.5
        navbarTitle.adjustsFontSizeToFitWidth = true
        navigationItem.titleView = navbarTitle
    }
    
    @objc private func onMorePressed(_ sender: Any) {
        let item = WrapData(timelineResponse: timelineResponse!)
        self.item = item
        let isSaved = timelineResponse?.saved ?? false
        threeDotMenuManager.showActions(sender: sender, item: item, isSaved: isSaved)
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
