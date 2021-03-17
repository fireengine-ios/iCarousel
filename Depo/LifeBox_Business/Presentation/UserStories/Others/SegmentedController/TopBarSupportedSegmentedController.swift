//
//  CustomTopBarSupportedSegmentedController.swift
//  Depo
//
//  Created by Alex Developer on 15.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

protocol SegmentedChildTopBarSupportedControllerProtocol: class {
    func setNavBarStyle(_ style: NavigationBarStyles)
    func setTitle(_ title: String, _ isLargeTitleEnabled: Bool)
    func changeNavbarLargeTitle(_ isEnabled: Bool)
    func setNavSearchConntroller(_ controller: UISearchController?)
    func setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool)
    func setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool)
}

extension SegmentedChildTopBarSupportedControllerProtocol where Self: UIViewController {

    private var currenttNavigationItem: UINavigationItem {
        return parentVC?.navigationItem ?? navigationItem
    }
    
    private var parentVC: TopBarSupportedSegmentedController? {
        return parent as? TopBarSupportedSegmentedController
    }

    private var currentViewController: UIViewController {
        return parentVC ?? self
    }
    
    func setNavBarStyle(_ style: NavigationBarStyles) {
        currentViewController.setNavigationBarStyle(style)
    }
    
    func setTitle(_ title: String, _ isLargeTitleEnabled: Bool) {
        if let parent = parentVC {
            parent.setNavigationTitle(title: parent.title ?? "", isLargeTitle: isLargeTitleEnabled)
        } else  {
            setNavigationTitle(title: title, isLargeTitle: isLargeTitleEnabled)
        }
    }
    
    func changeNavbarLargeTitle(_ isEnabled: Bool) {
        currentViewController.changeLargeTitle(prefersLargeTitles: isEnabled)
    }
    
    func setNavSearchConntroller(_ controller: UISearchController?) {
        currentViewController.changeSearchBar(controller: controller)
    }
    
    func setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        let navItem = currenttNavigationItem
        navItem.leftBarButtonItems = nil
        navItem.setLeftBarButtonItems(items, animated: animated)
    }

    func setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        let navItem = currenttNavigationItem
        navItem.rightBarButtonItems = nil
        navItem.setRightBarButtonItems(items, animated: animated)
    }
}

final class TopBarSupportedSegmentedController: BaseViewController, NibInit {
    
    private let topBarCustomSegmentedBar: TopBarCustomSegmentedView = TopBarCustomSegmentedView.initFromNib()
    
    private(set) var viewControllers = [PrivateShareSharedFilesViewController]()
    
    private var currentController: UIViewController? {
        guard
            !viewControllers.isEmpty,
            currentIndex < viewControllers.count
        else {
            return nil
        }
        return viewControllers[safe: currentIndex]
    }
    
    private var currentIndex: Int = 0
    
    private var collectionTopYInset: CGFloat = 0
    
    
    class func initWithControllers(with controllers: [UIViewController], currentIndex: Int = 0) -> TopBarSupportedSegmentedController {
        let controller = TopBarSupportedSegmentedController.initFromNib()
        let privateShareControllers: [PrivateShareSharedFilesViewController] = controllers.compactMap {
           return $0 as? PrivateShareSharedFilesViewController
        }
        controller.title = TextConstants.navbarRootTitleMySharings
        controller.setup(with: privateShareControllers)
        return controller
    }
    
    func setup(with controllers: [PrivateShareSharedFilesViewController], currentIndex: Int = 0) {
        guard !controllers.isEmpty else {
            assertionFailure()
            return
        }
        self.currentIndex = currentIndex
        viewControllers = controllers
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        needToShowTabBar = true
        
        setupContainer()
    }
     
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.navigationBar.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        navigationController?.navigationBar.removeObserver(self, forKeyPath: "frame")
//    }
    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "frame", let navBarFrame = navigationController?.navigationBar.frame {
//            debugPrint("!!!!! nav frame  \(navBarFrame)")
////            navBarFrame.origin.y
//            var newY = navBarFrame.height - 153 - 40 //- 48
////            if let searchFrame = navigationController?.navigationItem.searchController?.view.frame {
////                newY -= searchFrame.height
////            }
////        height += navBar?.frame.height ?? 0 // debug this as well
//            debugPrint("!!!!! nav newY  \(newY)")
//            if newY > 0 {
//                debugPrint("!121! currentController \(currentController?.view.frame.origin.y)")
//
//                topBarCustomSegmentedBar.frame = CGRect(x: 0, y: navBarFrame.height - 40 , width: view.frame.width, height: 40)
//            } else {
//                topBarCustomSegmentedBar.frame = CGRect(x: 0, y: 0 , width: view.frame.width, height: 40)
//            }
//
//        }
//    }
    
    private func setupContainer() {
        changeChildVC(index: currentIndex)
        setupSegmentedBar()
    }
    
    private func prepareModels() -> [TopBarCustomSegmentedViewButtonModel] {
        guard !viewControllers.isEmpty else {
            return []
        }
        var models = [TopBarCustomSegmentedViewButtonModel]()
        for (i, viewController) in viewControllers.enumerated() {
            let model = TopBarCustomSegmentedViewButtonModel(title: viewController.title ?? "") { [weak self] in
                self?.handleSegmentedAction(index: i)
            }
            models.append(model)
        }
        
        return models
    }
    
    private func setupSegmentedBar() {

//        topBarCustomSegmentedBar.translatesAutoresizingMaskIntoConstraints = false
        topBarCustomSegmentedBar.setup(models: prepareModels() , selectedIndex: 0)
        
        
        view.addSubview(topBarCustomSegmentedBar)

        topBarCustomSegmentedBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        
        collectionTopYInset += topBarCustomSegmentedBar.frame.height
        
        
//        topBarCustomSegmentedBar.
        
//        let topConstraint = topBarCustomSegmentedBar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0)
//        topConstraint.priority = .defaultLow
//
//
//        let topv2 = NSLayoutConstraint(item: topBarCustomSegmentedBar, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: view, attribute: .top, multiplier: 1, constant: 0)
//        topv2.priority = .defaultHigh
//
//
//        let leading = topBarCustomSegmentedBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0)
//        let trailing = topBarCustomSegmentedBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0)
//
//
//        NSLayoutConstraint.activate([leading, trailing,topConstraint, topv2])
    }
    
    private func handleSegmentedAction(index: Int) {
        changeChildVC(index: index)
    }
    
    private func changeChildVC(index: Int) {
        guard !viewControllers.isEmpty,
              index < viewControllers.count,
              let newChildVC = viewControllers[safe: index]
        else {
            return
        }
        
        
        currentIndex = index
        
        childViewControllers.forEach { $0.removeFromParentVC() }
//        if let currentContrroller = currentController {
//            childView
//        }
        
        newChildVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addChildViewController(newChildVC)
        view.addSubview(newChildVC.view)
        
        newChildVC.view.frame = CGRect(x: 0, y: topBarCustomSegmentedBar.frame.height, width: view.bounds.width, height: view.bounds.height)
        newChildVC.didMove(toParentViewController: self)
        
        
        topBarCustomSegmentedBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        
        view.bringSubview(toFront: topBarCustomSegmentedBar)
        //sendSubviewToBack
        
//        topBarCustomSegmentedBar.bottomAnchor.constraint(equalTo: newChildVC.view.topAnchor, constant: 0)
        
//        topBarCustomSegmentedBar
        
//        view.layoutSubviews()
    }
    
}
