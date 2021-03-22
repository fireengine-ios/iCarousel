//
//  CustomTopBarSupportedSegmentedController.swift
//  Depo
//
//  Created by Alex Developer on 15.03.2021.
//  Copyright © 2021 LifeTech. All rights reserved.
//

protocol SegmentedChildTopBarSupportedControllerProtocol: class {
    func setNavBarStyle(_ style: NavigationBarStyles)
    func setTitle(_ title: String, isSelectionMode: Bool, style: NavigationBarStyles)
    func changeNavbarLargeTitle(_ isEnabled: Bool, style: NavigationBarStyles)
    func setNavSearchConntroller(_ controller: UISearchController?)
    func setExtendedLayoutNavBar(extendedLayoutIncludesOpaqueBars: Bool)
    func setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool)
    func setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool)
}

extension SegmentedChildTopBarSupportedControllerProtocol where Self: UIViewController {

    private var currenttNavigationItem: UINavigationItem {
        return currentViewController.navigationItem
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
    
    func setTitle(_ title: String, isSelectionMode: Bool, style: NavigationBarStyles) {
        currentViewController.setNavigationTitle(title: title, style: style)
    }
    
    func changeNavbarLargeTitle(_ isEnabled: Bool, style: NavigationBarStyles) {
        currentViewController.changeLargeTitle(prefersLargeTitles: isEnabled, barStyle: style)
    }
    
    func setNavSearchConntroller(_ controller: UISearchController?) {
        currentViewController.changeSearchBar(controller: controller)
    }
    
    func setExtendedLayoutNavBar(extendedLayoutIncludesOpaqueBars: Bool) {
        
        //FIXME: temporary solution so segmented coontroler would function well enough
//        currentViewController
        self.extendedLayoutIncludesOpaqueBars = extendedLayoutIncludesOpaqueBars
        currentViewController.view.layoutSubviews()
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
    
    let rootTitle = TextConstants.navbarRootTitleMySharings
    
    class func initWithControllers(with controllers: [UIViewController], currentIndex: Int = 0) -> TopBarSupportedSegmentedController {
        let controller = TopBarSupportedSegmentedController.initFromNib()
        let privateShareControllers: [PrivateShareSharedFilesViewController] = controllers.compactMap {
            if let privateShareFilesController = $0 as? PrivateShareSharedFilesViewController {
                privateShareFilesController.offsetChangedDelegate = controller
                return privateShareFilesController
            }
           return nil
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
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
        topBarCustomSegmentedBar.setup(models: prepareModels() , selectedIndex: 0)
        view.addSubview(topBarCustomSegmentedBar)

        topBarCustomSegmentedBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        
        collectionTopYInset += topBarCustomSegmentedBar.frame.height
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
        
        newChildVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addChildViewController(newChildVC)
        view.addSubview(newChildVC.view)
        
        newChildVC.view.frame = CGRect(x: 0, y: topBarCustomSegmentedBar.frame.height, width: view.bounds.width, height: view.bounds.height)
        newChildVC.didMove(toParentViewController: self)
        
        topBarCustomSegmentedBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        
        view.bringSubview(toFront: topBarCustomSegmentedBar)
    }
    
}

extension TopBarSupportedSegmentedController:  PrivateShareSharedFilesViewControllerOffsetChangeDelegate {
    //TODO: check for the better solution (nav bar frame obsevation didnt produce satisfying result)
    func offsettChanged(newOffSet: CGFloat) {
        let newY: CGFloat = (newOffSet < 0) ? -newOffSet : 0
        topBarCustomSegmentedBar.frame = CGRect(x: 0, y: newY, width: view.frame.width, height: 40)
    }
}
