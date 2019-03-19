//
//  SegmentedController.swift
//  Depo
//
//  Created by Bondar Yaroslav on 8/16/18.
//  Copyright © 2018 LifeTech. All rights reserved.
//

import Foundation

//protocol SegmentedChildController: class {
//    func setTitle(_ title: String)
//    func setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool)
//    func setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool)
//}
//extension SegmentedChildController where Self: UIViewController {
//
//    private var parentVC: SegmentedController? {
//        return parent as? SegmentedController
//    }
//
//    func setTitle(_ title: String) {
//        parentVC?.navigationItem.title = title
//    }
//
//    func setLeftBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
//        parentVC?.navigationItem.setLeftBarButtonItems(items, animated: animated)
//    }
//
//    func setRightBarButtonItems(_ items: [UIBarButtonItem]?, animated: Bool) {
//        parentVC?.navigationItem.setRightBarButtonItems(items, animated: animated)
//    }
//}

//protocol SegmentedControllerDelegate: class {
//    func segmentedControllerEndEditMode()
//}

final class SegmentedController: BaseViewController, NibInit {
    
    static func initWithControllers(_ controllers: [UIViewController]) -> SegmentedController {
        let controller = SegmentedController.initFromNib()
        controller.setup(with: controllers)
        return controller
    }
    
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var segmentedControl: UISegmentedControl! {
        willSet {
            newValue.tintColor = ColorConstants.darkBlueColor
            newValue.setTitleTextAttributes([NSAttributedStringKey.font: UIFont.TurkcellSaturaRegFont(size: 14)],
                                            for: .normal)
        }
    }
    
    private var viewControllers: [BaseViewController] = []
    
    // TODO: - make safe -
    var currentController: UIViewController {
        return viewControllers[segmentedControl.selectedSegmentIndex]
    }
    
//    weak var delegate: SegmentedControllerDelegate?
    
//    private lazy var cancelSelectionButton = UIBarButtonItem(
//        title: TextConstants.cancelSelectionButtonTitle,
//        font: .TurkcellSaturaDemFont(size: 19.0),
//        target: self,
//        selector: #selector(onCancelSelectionButton))
    
//    @objc private func onCancelSelectionButton() {
//        delegate?.segmentedControllerEndEditMode()
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        homePageNavigationBarStyle()//without refactor
//        navigationBarWithGradientStyle()
        needShowTabBar = true
        setupSegmentedControl()
    }
    
    private func setupSegmentedControl() {
        segmentedControl.removeAllSegments()
        
        guard !viewControllers.isEmpty else {
            assertionFailure()
            return
        }
        
        for (index, controller) in viewControllers.enumerated() {
            segmentedControl.insertSegment(withTitle: controller.title, at: index, animated: false)
        }
        
        /// selectedSegmentIndex == -1 after removeAllSegments
        segmentedControl.selectedSegmentIndex = 0
        setupSelectedController(viewControllers[segmentedControl.selectedSegmentIndex])
    }
    
    private func setup(with controllers: [UIViewController]) {
        guard !controllers.isEmpty, let controllers = controllers as? [BaseViewController] else {
            assertionFailure()
            return
        }
        viewControllers = controllers
    }
    
    @IBAction private func segmentDidChange(_ sender: UISegmentedControl) {
        
        let selectedIndex = sender.selectedSegmentIndex
        
        guard selectedIndex < viewControllers.count else {
            assertionFailure()
            return
        }
        
        childViewControllers.forEach { $0.removeFromParentVC() }
        setupSelectedController(viewControllers[selectedIndex])
    }
    
    private func setupSelectedController(_ controller: BaseViewController) {
        add(childController: controller)
        floatingButtonsArray = controller.floatingButtonsArray
    }
    
    private func add(childController: UIViewController) {
        addChildViewController(childController)
        childController.view.frame = containerView.bounds
        childController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        containerView.addSubview(childController.view)
        childController.didMove(toParentViewController: self)
    }
}

//extension SegmentedController: PhotoVideoDataSourceDelegate {
//    func selectedModeDidChange(_ selectingMode: Bool) {
//        if selectingMode {
//            navigationItem.leftBarButtonItem = cancelSelectionButton
//        } else {
//            navigationItem.leftBarButtonItem = nil
//        }
//    }
//}

extension UIViewController {
    
    func removeFromParentVC() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
    }
}

